import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/location_service.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/destination_display_util.dart';
import '../../../shared/widgets/destination_card_compact.dart';
import '../../../shared/widgets/destination_card_large.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../favorites/data/favorites_local_datasource.dart';
import '../../home/presentation/home_controller.dart';
import 'explore_controller.dart';
import 'widgets/map_preview_strip.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  static const int _pageSize = 20;

  void _resetPage(WidgetRef ref) {
    ref.read(explorePageProvider.notifier).state = 1;
  }

  Future<void> _toggleFavorite(
    WidgetRef ref,
    DestinationModel destination,
  ) async {
    await getIt<FavoritesLocalDataSource>().toggleFavorite(destination);

    // Keep the current lightweight behavior: refresh destination-backed views
    // without rebuilding unrelated routes. A dedicated favorite-id store can
    // replace this in the data-payload sprint.
    ref.invalidate(exploreResultsProvider);
    ref.invalidate(homeDestinationsProvider);
    ref.invalidate(featuredDestinationsProvider);
    ref.invalidate(nearbyDestinationsProvider);
  }

  void _showCategoryPicker(
      BuildContext context, WidgetRef ref, String? activeCategory) {
    const categories = <String?>[
      null,
      'Budaya',
      'Alam',
      'Kuliner',
      'Belanja',
      'Seni',
      'Aktivitas',
      'Sejarah',
      'Foto',
    ];

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Pilih kategori'),
        message:
            const Text('Filter destinasi tanpa memenuhi halaman dengan chip.'),
        actions: [
          for (final category in categories)
            CupertinoActionSheetAction(
              onPressed: () {
                ref.read(activeCategoryProvider.notifier).state = category;
                _resetPage(ref);
                Navigator.of(context).pop();
              },
              child: Text(
                category ?? 'Semua destinasi',
                style: TextStyle(
                  fontWeight: activeCategory == category
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(gridModeProvider);
    final sortByNearest = ref.watch(sortByNearestProvider);
    final activeCategory = ref.watch(activeCategoryProvider);
    final currentPage = ref.watch(explorePageProvider);
    final resetSignal = ref.watch(exploreResetSignalProvider);
    final location = ref.watch(exploreLocationProvider);
    final results = ref.watch(exploreResultsProvider);

    final locationReady = location.valueOrNull != null;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            sliver: SliverToBoxAdapter(
              child: _ExploreHeader(
                locationText: location.when(
                  data: (value) => value == null
                      ? 'Lokasi belum aktif'
                      : sortByNearest
                          ? 'Terdekat aktif'
                          : 'Semua tempat',
                  loading: () => 'Cek lokasi...',
                  error: (_, __) => 'Lokasi bermasalah',
                ),
                locationActive: sortByNearest && locationReady,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: _SearchField(
                resetSignal: resetSignal,
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                  _resetPage(ref);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: _ExploreControlPanel(
                categoryLabel: activeCategory ?? 'Semua',
                sortLabel: sortByNearest ? 'Terdekat' : 'Kurasi',
                layoutLabel: isGrid ? 'Kartu' : 'List',
                isNearestActive: sortByNearest && locationReady,
                onCategoryTap: () =>
                    _showCategoryPicker(context, ref, activeCategory),
                onSortTap: () {
                  ref.read(sortByNearestProvider.notifier).state =
                      !sortByNearest;
                  _resetPage(ref);
                },
                onLayoutTap: () =>
                    ref.read(gridModeProvider.notifier).state = !isGrid,
                onResetTap: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(activeCategoryProvider.notifier).state = null;
                  ref.read(sortByNearestProvider.notifier).state = true;
                  ref.read(gridModeProvider.notifier).state = true;
                  ref.read(exploreResetSignalProvider.notifier).state++;
                  ref.invalidate(exploreLocationProvider);
                  _resetPage(ref);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ...results.when<List<Widget>>(
            data: (items) {
              final totalPages = math.max(1, (items.length / _pageSize).ceil());
              final safePage = currentPage.clamp(1, totalPages).toInt();
              final start = items.isEmpty ? 0 : (safePage - 1) * _pageSize;
              final end = math.min(start + _pageSize, items.length);
              final pageItems = items.isEmpty
                  ? <DestinationModel>[]
                  : items.sublist(start, end);
              final position = location.valueOrNull;
              final distanceLabels = <String, String>{};

              if (position != null) {
                final locationService = getIt<LocationService>();
                for (final item in pageItems) {
                  final meters = locationService.distanceInMeters(
                    fromLat: position.latitude,
                    fromLon: position.longitude,
                    toLat: item.latitude,
                    toLon: item.longitude,
                  );

                  distanceLabels[item.id] =
                      locationService.formatDistance(meters);
                }
              }

              return [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: MapPreviewStrip(
                      destinations: pageItems,
                      userLatitude: position?.latitude,
                      userLongitude: position?.longitude,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: sortByNearest && position != null
                          ? 'Terdekat dari Lokasimu'
                          : activeCategory ?? 'Semua Destinasi',
                      subtitle: items.isEmpty
                          ? 'Tidak ada hasil'
                          : '${start + 1}-$end dari ${items.length}',
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                if (pageItems.isEmpty)
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                  )
                else if (isGrid)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisExtent: 240,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final destination = pageItems[index];
                          return RepaintBoundary(
                            child: DestinationCardLarge(
                              destination: destination,
                              distanceLabel: distanceLabels[destination.id] ??
                                  '${destination.rating.toStringAsFixed(1)} ★',
                              onTap: () => context.push(
                                  '${RouteNames.destination}/${destination.id}'),
                              onFavoriteToggle: () =>
                                  _toggleFavorite(ref, destination),
                            ),
                          );
                        },
                        childCount: pageItems.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final destination = pageItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RepaintBoundary(
                              child: DestinationCardCompact(
                                destination: destination,
                                subtitle: distanceLabels[destination.id] == null
                                    ? '${DestinationDisplayUtil.categoryFor(destination)} • rating ${destination.rating.toStringAsFixed(1)}'
                                    : '${distanceLabels[destination.id]} • ${DestinationDisplayUtil.categoryFor(destination)}',
                                onTap: () => context.push(
                                    '${RouteNames.destination}/${destination.id}'),
                                onFavoriteToggle: () =>
                                    _toggleFavorite(ref, destination),
                              ),
                            ),
                          );
                        },
                        childCount: pageItems.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 126),
                  sliver: SliverToBoxAdapter(
                    child: _PaginationControls(
                      page: safePage,
                      totalPages: totalPages,
                      canPrevious: safePage > 1,
                      canNext: safePage < totalPages,
                      onPrevious: () => ref
                          .read(explorePageProvider.notifier)
                          .state = safePage - 1,
                      onNext: () => ref
                          .read(explorePageProvider.notifier)
                          .state = safePage + 1,
                    ),
                  ),
                ),
              ];
            },
            loading: () => [
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(child: LoadingSkeleton(height: 220)),
              ),
            ],
            error: (_, __) => const [
              SliverToBoxAdapter(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExploreControlPanel extends StatelessWidget {
  const _ExploreControlPanel({
    required this.categoryLabel,
    required this.sortLabel,
    required this.layoutLabel,
    required this.isNearestActive,
    required this.onCategoryTap,
    required this.onSortTap,
    required this.onLayoutTap,
    required this.onResetTap,
  });

  final String categoryLabel;
  final String sortLabel;
  final String layoutLabel;
  final bool isNearestActive;
  final VoidCallback onCategoryTap;
  final VoidCallback onSortTap;
  final VoidCallback onLayoutTap;
  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.07,
      borderRadius: 22,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _SelectPill(
            icon: CupertinoIcons.square_grid_2x2,
            label: 'Kategori',
            value: categoryLabel,
            onTap: onCategoryTap,
          ),
          _SelectPill(
            icon: isNearestActive
                ? CupertinoIcons.location_solid
                : CupertinoIcons.sort_down,
            label: 'Urut',
            value: sortLabel,
            active: isNearestActive,
            onTap: onSortTap,
          ),
          _SelectPill(
            icon: CupertinoIcons.rectangle_grid_1x2,
            label: 'Tampilan',
            value: layoutLabel,
            onTap: onLayoutTap,
          ),
          _SelectPill(
            icon: CupertinoIcons.arrow_counterclockwise,
            label: 'Reset',
            value: 'Bersihkan',
            onTap: onResetTap,
          ),
        ],
      ),
    );
  }
}

class _SelectPill extends StatelessWidget {
  const _SelectPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: 0.75,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: CupertinoColors.white.withOpacity(active ? 0.10 : 0.055),
          border: Border.all(color: CupertinoColors.white.withOpacity(0.085)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color:
                    active ? AppColors.accentPrimary : AppColors.textSecondary),
            const SizedBox(width: 7),
            Text(
              '$label: $value',
              style: AppTypography.captionSmall11.copyWith(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.page,
    required this.totalPages,
    required this.canPrevious,
    required this.canNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final bool canPrevious;
  final bool canNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _PageButton(
            label: '← Sebelumnya',
            enabled: canPrevious,
            onTap: onPrevious,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GlassCard(
            blur: 20,
            opacity: 0.06,
            borderRadius: 20,
            borderColor: CupertinoColors.white.withOpacity(0.09),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Text(
              '$page / $totalPages',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textMedium15.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _PageButton(
            label: 'Berikutnya →',
            enabled: canNext,
            onTap: onNext,
          ),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: enabled ? 0.72 : 1,
      onPressed: enabled ? onTap : null,
      child: GlassCard(
        blur: 24,
        opacity: enabled ? 0.09 : 0.035,
        borderRadius: 20,
        borderColor: CupertinoColors.white.withOpacity(enabled ? 0.11 : 0.06),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textMedium15.copyWith(
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary.withOpacity(0.55),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.15,
          ),
        ),
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({
    required this.locationText,
    required this.locationActive,
  });

  final String locationText;
  final bool locationActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jelajahi Jogja',
                style: AppTypography.displayBold34.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  letterSpacing: -1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Temukan destinasi terbaik di sekitarmu.',
                style: AppTypography.textRegular13.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 142),
          child: _LocationMiniBadge(
            text: locationText,
            active: locationActive,
          ),
        ),
      ],
    );
  }
}

class _LocationMiniBadge extends StatelessWidget {
  const _LocationMiniBadge({
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 24,
      opacity: active ? 0.09 : 0.065,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? CupertinoIcons.location_solid : CupertinoIcons.location,
            size: 13,
            color: active ? AppColors.accentPrimary : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.onChanged, required this.resetSignal});

  final ValueChanged<String> onChanged;
  final int resetSignal;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetSignal != widget.resetSignal &&
        _controller.text.isNotEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.073,
      borderRadius: 20,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: EdgeInsets.zero,
      child: CupertinoTextField.borderless(
        controller: _controller,
        placeholder: 'Cari candi, kuliner, pantai, atau fitur...',
        onChanged: widget.onChanged,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(
            CupertinoIcons.search,
            size: 17,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
        placeholderStyle: AppTypography.textRegular13.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        style: AppTypography.textRegular13.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: AppColors.textPrimary,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.displaySemi20.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.45,
            ),
          ),
        ),
        Text(
          subtitle,
          style: AppTypography.captionSmall11.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
