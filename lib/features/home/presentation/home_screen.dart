import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/data/auth_local_datasource.dart';
import '../../../shared/widgets/bottom_sheet_wrapper.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../data/weather_remote_datasource.dart';
import 'home_controller.dart';
import 'widgets/featured_destinations_row.dart';
import 'widgets/nearby_destinations_row.dart';
import 'widgets/quick_guide_row.dart';
import 'widgets/weather_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final Future<String> _usernameFuture;

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);
  static const _text = Color(0xFFF8F8FB);
  static const _muted = Color(0xFFA0A0AA);

  @override
  void initState() {
    super.initState();
    _usernameFuture = _loadUsername();
  }

  Future<String> _loadUsername() async {
    final user = await getIt<AuthLocalDataSource>().currentUser();
    final name = user?.name.trim();

    if (name == null || name.isEmpty) return 'Pelancong';
    return name.split(' ').first;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherProvider);
    final featured = ref.watch(featuredDestinationsProvider);
    final nearby = ref.watch(nearbyDestinationsProvider);

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
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<String>(
                    future: _usernameFuture,
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? 'Pelancong';

                      return _LiquidHomeHero(
                        name: name,
                        onNotificationTap: () {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (context) => const BottomSheetWrapper(
                              child: _NotificationPreview(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 132),
                sliver: SliverList.list(
                  children: [
                    const _HomeSearchBar(),
                    const SizedBox(height: 18),
                    featured.when(
                      data: (value) => _TodayTripCard(
                        destination: value.isEmpty ? null : value.first,
                      ),
                      loading: () => const LoadingSkeleton(height: 154),
                      error: (_, __) => const _TodayTripCard(),
                    ),
                    const SizedBox(height: 18),
                    weather.when(
                      data: (value) => WeatherBanner(weather: value),
                      loading: () => const LoadingSkeleton(height: 124),
                      error: (_, __) => WeatherBanner(
                        weather: WeatherModel.unavailable(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionHeader(
                      title: 'Akses Cepat',
                      subtitle: 'Pilih yang kamu butuhkan hari ini.',
                    ),
                    const SizedBox(height: 12),
                    const QuickGuideRow(),
                    const SizedBox(height: 28),
                    const _SectionHeader(
                      title: 'Destinasi Pilihan',
                      subtitle: 'Tempat menarik yang bisa kamu coba.',
                    ),
                    const SizedBox(height: 12),
                    featured.when(
                      data: (value) => FeaturedDestinationsRow(
                        destinations: value,
                      ),
                      loading: () => const LoadingSkeleton(height: 220),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 30),
                    _SectionHeader(
                      title: 'Di Sekitarmu',
                      subtitle: 'Tempat menarik yang dekat dari posisimu.',
                      actionLabel: 'Jelajahi',
                      onActionTap: () => context.go(RouteNames.explore),
                    ),
                    const SizedBox(height: 12),
                    nearby.when(
                      data: (value) => NearbyDestinationsRow(
                        destinations: value,
                      ),
                      loading: () => const LoadingSkeleton(height: 180),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidHomeHero extends StatelessWidget {
  const _LiquidHomeHero({
    required this.name,
    required this.onNotificationTap,
  });

  final String name;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JogjaSplorasi',
                  style: AppTypography.labelMedium12.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Halo, $name',
                  style: AppTypography.displayBold34.copyWith(
                    fontSize: 30,
                    letterSpacing: 0,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // NOTIFICATION BUTTON
          _NotificationButton(onTap: onNotificationTap),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatefulWidget {
  const _HomeSearchBar();

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        HapticFeedback.selectionClick();
        context.push(RouteNames.globalSearch);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          blur: 30,
          opacity: 0.073,
          borderRadius: 20,
          borderColor: CupertinoColors.white.withOpacity(0.10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.search,
                size: 18,
                color: AppColors.textSecondary.withOpacity(0.85),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cari candi, kuliner, pantai, atau fitur...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                size: 15,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _TodayTripCard extends StatefulWidget {
  const _TodayTripCard({this.destination});

  final DestinationModel? destination;

  @override
  State<_TodayTripCard> createState() => _TodayTripCardState();
}

class _TodayTripCardState extends State<_TodayTripCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final title = destination?.name ?? 'Jelajah spontan hari ini';
    final subtitle = destination == null
        ? 'Buka Jelajah dan biarkan Jogja kasih kejutan tempat terbaik buat mood kamu.'
        : 'Hari ini kamu harus mampir ke $title. Cocok buat mulai petualangan singkat tanpa ribet.';

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        HapticFeedback.selectionClick();
        if (destination == null) {
          context.go(RouteNames.explore);
          return;
        }
        context.push('${RouteNames.destination}/${destination.id}');
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          blur: 28,
          opacity: 0.078,
          borderRadius: 26,
          borderColor: CupertinoColors.white.withOpacity(0.12),
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 16, 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.15,
                colors: [
                  AppColors.accentPrimary.withOpacity(0.20),
                  AppColors.accentSecondary.withOpacity(0.10),
                  CupertinoColors.white.withOpacity(0.025),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentPrimary.withOpacity(0.17),
                  ),
                  child: const Icon(
                    CupertinoIcons.map_pin_ellipse,
                    size: 24,
                    color: AppColors.accentPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi perjalanan',
                        style: AppTypography.labelMedium12.copyWith(
                          color: AppColors.accentPrimary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.displaySemi22.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          letterSpacing: -0.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textRegular13.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.34,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  CupertinoIcons.chevron_right_circle_fill,
                  color: AppColors.accentPrimary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatefulWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
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
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CupertinoColors.white.withOpacity(0.12),
                CupertinoColors.white.withOpacity(0.045),
              ],
            ),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.13),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: -10,
                color: Color(0x97000000),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.bell,
            size: 20,
            color: _HomeScreenState._text,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

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
                title,
                style: AppTypography.displaySemi22.copyWith(
                  color: _HomeScreenState._text,
                  fontSize: 22,
                  letterSpacing: -0.45,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textRegular13.copyWith(
                    color: _HomeScreenState._muted,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onActionTap != null) ...[
          const SizedBox(width: AppSpacing.spaceXS),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: AppTypography.textMedium15.copyWith(
                color: AppColors.accentTertiary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Notifikasi', style: AppTypography.displaySemi22),
        const SizedBox(height: 10),
        Text(
          'Belum ada notifikasi baru. Rekomendasi pagi, favorit sore, dan quiz malam akan muncul di sini.',
          style: AppTypography.textRegular13.copyWith(height: 1.45),
        ),
      ],
    );
  }
}
