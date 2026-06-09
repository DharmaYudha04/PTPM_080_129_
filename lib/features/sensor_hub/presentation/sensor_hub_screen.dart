import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../notifications/notification_service.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/glass_card.dart';
import 'widgets/accel_graph.dart';
import 'widgets/gyro_cube_visualizer.dart';
import 'widgets/sensor_feature_card.dart';
import 'widgets/sensor_live_banner.dart';
import '../../../shared/widgets/jogja_page_header.dart';

final accelerometerProvider = StreamProvider<AccelerometerEvent>(
  (ref) => _safeAccelerometerStream(),
);

final gyroscopeProvider = StreamProvider<GyroscopeEvent>(
  (ref) => _safeGyroscopeStream(),
);

Stream<AccelerometerEvent> _safeAccelerometerStream() {
  if (kIsWeb) return const Stream<AccelerometerEvent>.empty();
  try {
    return accelerometerEventStream().handleError((_) {});
  } catch (_) {
    return const Stream<AccelerometerEvent>.empty();
  }
}

Stream<GyroscopeEvent> _safeGyroscopeStream() {
  if (kIsWeb) return const Stream<GyroscopeEvent>.empty();
  try {
    return gyroscopeEventStream().handleError((_) {});
  } catch (_) {
    return const Stream<GyroscopeEvent>.empty();
  }
}

class SensorHubScreen extends ConsumerStatefulWidget {
  const SensorHubScreen({super.key});

  @override
  ConsumerState<SensorHubScreen> createState() => _SensorHubScreenState();
}

class _SensorHubScreenState extends ConsumerState<SensorHubScreen> {
  final List<double> _values = [];
  StreamSubscription<AccelerometerEvent>? _subscription;

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  @override
  void initState() {
    super.initState();

    if (kIsWeb) return;

    _subscription = _safeAccelerometerStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      setState(() {
        _values.add(magnitude);
        if (_values.length > 28) _values.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _axisLabel(double x, double y, double z) {
    return '${x.toStringAsFixed(2)}  ${y.toStringAsFixed(2)}  ${z.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final accel = ref.watch(accelerometerProvider).value;
    final gyro = ref.watch(gyroscopeProvider).value;

    final isLive = !kIsWeb && accel != null && gyro != null;

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
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 126),
            children: [
              const JogjaPageHeader(
                  title: 'Coba Fitur HP',
                  subtitle:
                      'Coba gerakan HP dan notifikasi demo di satu tempat.'),
              const SizedBox(height: 18),
              SensorLiveBanner(
                live: isLive,
                accel: accel == null
                    ? 'Menunggu sensor...'
                    : _axisLabel(accel.x, accel.y, accel.z),
                gyro: gyro == null
                    ? 'Menunggu sensor...'
                    : _axisLabel(gyro.x, gyro.y, gyro.z),
              ),
              const SizedBox(height: 14),
              const _ShakeDiscoverPanel(),
              const SizedBox(height: 14),
              const _NotificationTestPanel(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SensorFeatureCard(
                      icon: CupertinoIcons.waveform_path_ecg,
                      label: 'Gerak',
                      value: isLive ? 'Aktif' : 'Coba',
                      color: AppColors.accentTertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SensorFeatureCard(
                      icon: CupertinoIcons.scope,
                      label: 'Gyro',
                      value: gyro == null ? 'Siap' : 'Aktif',
                      color: AppColors.accentSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SensorFeatureCard(
                      icon: CupertinoIcons.hand_raised_fill,
                      label: 'Goyang',
                      value: 'Siap',
                      color: AppColors.accentPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _SectionTitle(
                title: 'Gyroscope',
                subtitle: 'Pantau miring kiri/kanan HP',
              ),
              const SizedBox(height: 10),
              _LiquidPanel(
                child: GyroCubeVisualizer(
                  x: gyro?.x ?? 0,
                  y: gyro?.y ?? 0,
                ),
              ),
              const SizedBox(height: 22),
              const _SectionTitle(
                title: 'Accelerometer',
                subtitle: 'Grafik gerakan HP',
              ),
              const SizedBox(height: 10),
              _LiquidPanel(
                child: AccelGraph(
                  values: _values.isEmpty
                      ? const [9.4, 9.7, 9.2, 10.1, 9.6, 9.9, 9.5]
                      : _values,
                ),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 16),
                _WebNotice(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _SensorHeader extends StatelessWidget {
  const _SensorHeader({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sensor Hub',
                style: AppTypography.displayBold34.copyWith(
                  fontSize: 32,
                  letterSpacing: -1.05,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Pantau accelerometer, gyroscope, dan shake interaction.',
                style: AppTypography.textRegular13.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GlassCard(
          blur: 24,
          opacity: isLive ? 0.10 : 0.065,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.10),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLive
                      ? AppColors.accentTertiary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                isLive ? 'Live' : 'Web',
                style: AppTypography.captionSmall11.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _LiquidPanel extends StatelessWidget {
  const _LiquidPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 32,
      opacity: 0.074,
      borderRadius: 26,
      borderColor: CupertinoColors.white.withOpacity(0.11),
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 190),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.15,
              colors: [
                AppColors.accentSecondary.withOpacity(0.10),
                CupertinoColors.white.withOpacity(0.032),
                CupertinoColors.black.withOpacity(0.02),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _WebNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 28,
      opacity: 0.07,
      borderRadius: 22,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.info_circle,
            size: 18,
            color: AppColors.accentTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sensor live lebih stabil saat dijalankan di Android device/emulator.',
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTestPanel extends StatelessWidget {
  const _NotificationTestPanel();

  Future<void> _testNotification() async {
    await getIt<NotificationService>().showImmediate(
      'Monggo, ada tempat menarik di dekatmu',
      'Kanca Jogja punya rekomendasi buat jalan-jalan hari ini.',
      payload: NotificationPayload.explore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LiquidPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.bell_fill,
                    color: AppColors.accentPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coba Notifikasi',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.displaySemi20
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kirim contoh notifikasi untuk memastikan fitur berjalan di perangkatmu.',
                        style: AppTypography.textRegular13.copyWith(
                            color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                color: AppColors.accentPrimary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                onPressed: _testNotification,
                child: Text(
                  'Kirim Tes',
                  style: AppTypography.captionSmall11
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShakeDiscoverPanel extends StatefulWidget {
  const _ShakeDiscoverPanel();

  @override
  State<_ShakeDiscoverPanel> createState() => _ShakeDiscoverPanelState();
}

class _ShakeDiscoverPanelState extends State<_ShakeDiscoverPanel> {
  DestinationModel? _picked;

  void _pick() {
    final items = Hive.box<DestinationModel>(AppConstants.destinationsBox)
        .values
        .toList();
    if (items.isEmpty) return;
    setState(() => _picked = items[Random().nextInt(items.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    return _LiquidPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.hand_raised_fill,
                    color: AppColors.accentPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goyang untuk Rekomendasi',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.displaySemi20
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Goyangkan HP agak kuat untuk melihat saran tempat menarik.',
                        style: AppTypography.textRegular13.copyWith(
                            color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                color: AppColors.accentPrimary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                onPressed: _pick,
                child: Text(
                  'Coba Sekarang',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSmall11
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
            if (picked != null) ...[
              const SizedBox(height: 14),
              Text(
                picked.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.displaySemi22
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 5),
              Text(
                picked.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textRegular13
                    .copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 10),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                color: AppColors.accentPrimary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                onPressed: () =>
                    context.push('${RouteNames.destination}/${picked.id}'),
                child: Text(
                  'Lihat Tempat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSmall11.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
