import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/destination_display_util.dart';
import '../../../core/utils/destination_image_resolver.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../home/data/weather_remote_datasource.dart';
import '../../explore/data/destinations_remote_datasource.dart';
import '../../explore/presentation/explore_controller.dart';
import '../../favorites/data/favorites_local_datasource.dart';
import '../../home/presentation/home_controller.dart';
import 'widgets/ai_guide_teaser.dart';
import 'widgets/info_strip.dart';
import 'widgets/parallax_hero.dart';
import 'widgets/similar_destinations.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  const DestinationDetailScreen({
    required this.destinationId,
    super.key,
  });

  final String destinationId;

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends ConsumerState<DestinationDetailScreen> {
  late final DestinationsRemoteDataSource _destinationsDataSource;
  late final FavoritesLocalDataSource _favoritesDataSource;
  late Future<DestinationModel> _destinationFuture;
  DestinationModel? _destination;

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  @override
  void initState() {
    super.initState();
    _destinationsDataSource = getIt<DestinationsRemoteDataSource>();
    _favoritesDataSource = getIt<FavoritesLocalDataSource>();
    _destination =
        _destinationsDataSource.getCachedDestination(widget.destinationId);
    _destinationFuture = _loadDestination();
  }

  Future<DestinationModel> _loadDestination() async {
    final destination = await _destinationsDataSource
        .fetchDestinationDetail(widget.destinationId);
    final updated = destination.copyWith(
      isFavorite: _favoritesDataSource.isFavorite(destination.id,
          fallback: destination.isFavorite),
    );
    _destination = updated;
    return updated;
  }

  Future<void> _toggleFavorite(DestinationModel destination) async {
    HapticFeedback.selectionClick();

    await _favoritesDataSource.toggleFavorite(destination);
    final updated = destination.copyWith(
      isFavorite: _favoritesDataSource.isFavorite(destination.id,
          fallback: !destination.isFavorite),
    );

    ref.invalidate(exploreResultsProvider);
    ref.invalidate(featuredDestinationsProvider);
    ref.invalidate(nearbyDestinationsProvider);

    if (!mounted) return;

    setState(() => _destination = updated);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(
          updated.isFavorite
              ? 'Ditambahkan ke favorit'
              : 'Dihapus dari favorit',
        ),
        message: const Text(
            'Perubahan disimpan lokal dan akan disinkronkan ke backend.'),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => context.pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  Future<void> _startNavigation(DestinationModel destination) async {
    HapticFeedback.lightImpact();

    final success = await getIt<LocationService>().openDestinationMap(
      destination,
    );

    if (!mounted || success) return;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Maps tidak bisa dibuka'),
        message: const Text(
          'Coba cek aplikasi maps atau koneksi internet kamu.',
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => context.pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DestinationModel>(
      future: _destinationFuture,
      initialData: _destination,
      builder: (context, snapshot) {
        final destination = snapshot.data;

        if (destination == null) {
          if (snapshot.hasError) {
            return CupertinoPageScaffold(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    humanizeError(snapshot.error ??
                        const AppException('Destinasi tidak ditemukan.')),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        final similar = _destinationsDataSource.cachedSimilar(destination);

        return CupertinoPageScaffold(
          backgroundColor: _bgBottom,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.18,
                colors: [
                  Color(0xFF282836),
                  _bgTop,
                  _bgMid,
                  _bgBottom,
                ],
                stops: [0, 0.32, 0.68, 1],
              ),
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _DetailHero(destination: destination),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 132),
                      sliver: SliverList.list(
                        children: [
                          FutureBuilder<String>(
                            future: getIt<LocationService>()
                                .getCurrentPositionOrNull()
                                .then((position) {
                              if (position == null) return 'Lokasi belum aktif';

                              final meters =
                                  getIt<LocationService>().distanceInMeters(
                                fromLat: position.latitude,
                                fromLon: position.longitude,
                                toLat: destination.latitude,
                                toLon: destination.longitude,
                              );

                              return getIt<LocationService>()
                                  .formatDistance(meters);
                            }),
                            builder: (context, snapshot) {
                              final label =
                                  snapshot.data ?? 'Menghitung jarak...';
                              return _DistancePill(label: label);
                            },
                          ),
                          const SizedBox(height: 16),
                          InfoStrip(destination: destination),
                          const SizedBox(height: 16),
                          AIGuideTeaser(destinationName: destination.name),
                          const SizedBox(height: 24),
                          const _SectionTitle('Tentang'),
                          const SizedBox(height: 10),
                          _LiquidTextCard(text: destination.description),
                          const SizedBox(height: 24),
                          const _SectionTitle('Cuaca Lokal'),
                          const SizedBox(height: 10),
                          FutureBuilder<WeatherModel>(
                            future: WeatherRemoteDataSource(
                              dio: Dio(),
                              prefs: getIt(),
                            ).fetchWeather(
                              lat: destination.latitude,
                              lon: destination.longitude,
                            ),
                            builder: (context, snapshot) {
                              return _WeatherMiniCard(weather: snapshot.data);
                            },
                          ),
                          if (similar.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const _SectionTitle('Destinasi Serupa'),
                            const SizedBox(height: 10),
                            SimilarDestinations(items: similar),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 48,
                  left: 20,
                  child: _CircleGlassButton(
                    icon: CupertinoIcons.chevron_left,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.pop();
                    },
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: _BottomActions(
                    isFavorite: destination.isFavorite,
                    onFavoriteTap: () => _toggleFavorite(destination),
                    onNavigationTap: () => _startNavigation(destination),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ParallaxHero(
              tag: 'destination-${destination.id}',
              imageUrl: DestinationImageResolver.resolve(destination),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withOpacity(0.02),
                    CupertinoColors.black.withOpacity(0.18),
                    _DestinationDetailScreenState._bgBottom.withOpacity(0.98),
                  ],
                  stops: const [0, 0.56, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryRatingPill(
                  category: DestinationDisplayUtil.categoryFor(destination),
                  rating: destination.rating,
                ),
                const SizedBox(height: 12),
                Text(
                  destination.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displayBold34.copyWith(
                    fontSize: 34,
                    height: 1.02,
                    letterSpacing: -1.15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRatingPill extends StatelessWidget {
  const _CategoryRatingPill({
    required this.category,
    required this.rating,
  });

  final String category;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final categoryMaxWidth =
        (MediaQuery.sizeOf(context).width - 116).clamp(96.0, 240.0).toDouble();

    return GlassCard(
      blur: 26,
      opacity: 0.09,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.13),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: categoryMaxWidth),
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textSecondary.withOpacity(0.75),
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.star_fill,
            size: 12,
            color: AppColors.accentTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistancePill extends StatelessWidget {
  const _DistancePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 28,
      opacity: 0.075,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.location_solid,
            size: 16,
            color: AppColors.accentPrimary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidTextCard extends StatelessWidget {
  const _LiquidTextCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.072,
      borderRadius: 24,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Text(
        text,
        style: AppTypography.textRegular13.copyWith(
          color: AppColors.textSecondary,
          height: 1.55,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _WeatherMiniCard extends StatelessWidget {
  const _WeatherMiniCard({required this.weather});

  final WeatherModel? weather;

  @override
  Widget build(BuildContext context) {
    final loading = weather == null;

    return GlassCard(
      blur: 30,
      opacity: 0.075,
      borderRadius: 24,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentTertiary.withOpacity(0.14),
            ),
            child: const Icon(
              CupertinoIcons.cloud_sun_fill,
              size: 20,
              color: AppColors.accentTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: loading
                ? Text(
                    'Memuat cuaca atau data cuaca belum tersedia...',
                    style: AppTypography.textRegular13.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather!.temp.toStringAsFixed(0)}°C',
                        style: AppTypography.displaySemi22.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        weather!.condition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textRegular13.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.displaySemi20.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
    );
  }
}

class _CircleGlassButton extends StatefulWidget {
  const _CircleGlassButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CircleGlassButton> createState() => _CircleGlassButtonState();
}

class _CircleGlassButtonState extends State<_CircleGlassButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isBack = widget.icon == CupertinoIcons.chevron_left;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          width: 50,
          height: 50,
          blur: 30,
          opacity: 0.095,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.13),
          padding: EdgeInsets.zero,
          child: Center(
            child: Transform.translate(
              offset: Offset(isBack ? -2 : 0, 0),
              child: Icon(
                widget.icon,
                size: 22,
                color: AppColors.accentPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onNavigationTap,
  });

  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onNavigationTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.09,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.13),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _BottomActionButton(
              label: isFavorite ? 'Tersimpan' : 'Favorit',
              filled: false,
              onTap: onFavoriteTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _BottomActionButton(
              label: 'Start Navigation',
              filled: true,
              onTap: onNavigationTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionButton extends StatefulWidget {
  const _BottomActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_BottomActionButton> createState() => _BottomActionButtonState();
}

class _BottomActionButtonState extends State<_BottomActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: widget.filled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentPrimary.withOpacity(0.95),
                      AppColors.accentPrimary.withOpacity(0.72),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CupertinoColors.white.withOpacity(0.095),
                      CupertinoColors.white.withOpacity(0.038),
                    ],
                  ),
            border: Border.all(
              color: widget.filled
                  ? CupertinoColors.white.withOpacity(0.18)
                  : CupertinoColors.white.withOpacity(0.10),
              width: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textMedium15.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
