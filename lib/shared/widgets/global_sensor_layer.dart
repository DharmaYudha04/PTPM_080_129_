import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../models/destination.dart';
import 'glass_card.dart';

class GlobalSensorLayer extends StatefulWidget {
  const GlobalSensorLayer({required this.child, super.key});

  final Widget child;

  @override
  State<GlobalSensorLayer> createState() => _GlobalSensorLayerState();
}

class _GlobalSensorLayerState extends State<GlobalSensorLayer>
    with WidgetsBindingObserver {
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSub;
  DateTime _lastShake = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastShakePeak = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastTilt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastAccelerometerRead = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastGyroscopeRead = DateTime.fromMillisecondsSinceEpoch(0);
  bool _showingRecommendation = false;

  static const _sensorGesturesEnabled = bool.fromEnvironment(
    'JOGJA_SENSOR_GESTURES',
    defaultValue: false,
  );
  static const _sensorThrottle = Duration(milliseconds: 160);
  static const _shakeThreshold = 28.0;
  static const _shakeConfirmationWindow = Duration(milliseconds: 650);
  static const _sideTiltThreshold = 4.6;
  static const _cooldown = Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startSensors();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startSensors();
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopSensors();
    }
  }

  void _startSensors() {
    if (kIsWeb || !_sensorGesturesEnabled) return;
    if (_accelerometerSub != null || _gyroscopeSub != null) return;

    try {
      _accelerometerSub = accelerometerEventStream().listen(
        _handleAccelerometer,
        onError: (_) {},
        cancelOnError: false,
      );
      _gyroscopeSub = gyroscopeEventStream().listen(
        _handleGyroscope,
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {
      // Sensor tidak selalu tersedia di web/emulator. Fitur utama tetap aman.
    }
  }

  void _stopSensors() {
    _accelerometerSub?.cancel();
    _gyroscopeSub?.cancel();
    _accelerometerSub = null;
    _gyroscopeSub = null;
  }

  void _handleAccelerometer(AccelerometerEvent event) {
    if (!_canProcessAccelerometer()) return;
    final now = DateTime.now();
    final magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (magnitude < _shakeThreshold) return;
    final confirmedShake =
        now.difference(_lastShakePeak) <= _shakeConfirmationWindow;
    _lastShakePeak = now;
    if (!confirmedShake) return;
    if (!_ready(_lastShake)) return;
    _lastShake = now;
    _showDestinationReason('Rekomendasi buat hari ini');
  }

  void _handleGyroscope(GyroscopeEvent event) {
    if (!_canProcessGyroscope()) return;
    // Fokus pada putaran samping kiri/kanan. Gerakan kecil, angkat-taruh HP,
    // atau tilt atas-bawah tidak langsung memicu rekomendasi.
    final sideTurn = event.y.abs();
    final verticalNoise = event.x.abs();
    if (sideTurn < _sideTiltThreshold || verticalNoise > sideTurn * 0.9) return;
    if (!_ready(_lastTilt)) return;
    _lastTilt = DateTime.now();
    _showDestinationReason('Kanca Jogja nemu tempat seru');
  }

  bool _canProcessAccelerometer() {
    final now = DateTime.now();
    if (now.difference(_lastAccelerometerRead) < _sensorThrottle) return false;
    _lastAccelerometerRead = now;
    return true;
  }

  bool _canProcessGyroscope() {
    final now = DateTime.now();
    if (now.difference(_lastGyroscopeRead) < _sensorThrottle) return false;
    _lastGyroscopeRead = now;
    return true;
  }

  bool _ready(DateTime last) {
    if (_showingRecommendation) return false;
    return DateTime.now().difference(last) > _cooldown;
  }

  DestinationModel? _pickDestination() {
    final box = Hive.box<DestinationModel>(AppConstants.destinationsBox);
    final items =
        box.values.where((item) => item.name.trim().isNotEmpty).toList();
    if (items.isEmpty) return null;

    final featured =
        items.where((item) => item.rating >= 4.6 || item.isFavorite).toList();
    final pool = featured.isEmpty ? items : featured;
    return pool[Random().nextInt(pool.length)];
  }

  Future<void> _showDestinationReason(String title) async {
    final destination = _pickDestination();
    if (destination == null || !mounted) return;

    _showingRecommendation = true;
    HapticFeedback.mediumImpact();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup rekomendasi',
      barrierColor: CupertinoColors.black.withOpacity(0.58),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, __) {
        return Center(
          child: _SensorRecommendationDialog(
            title: title,
            destination: destination,
            onClose: () => Navigator.of(dialogContext).pop(),
            onOpen: () {
              Navigator.of(dialogContext).pop();
              if (!mounted) return;
              context.push('${RouteNames.destination}/${destination.id}');
            },
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
                      .animate(curved),
              child: child,
            ),
          ),
        );
      },
    );

    _showingRecommendation = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopSensors();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SensorRecommendationDialog extends StatelessWidget {
  const _SensorRecommendationDialog({
    required this.title,
    required this.destination,
    required this.onClose,
    required this.onOpen,
  });

  final String title;
  final DestinationModel destination;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final category = destination.category.trim().isEmpty
        ? 'Wisata'
        : destination.category.trim();
    final description = destination.description.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: GlassCard(
          blur: 38,
          opacity: 0.102,
          borderRadius: 30,
          borderColor: AppColors.accentPrimary.withOpacity(0.28),
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.15,
                colors: [
                  AppColors.accentPrimary.withOpacity(0.16),
                  CupertinoColors.white.withOpacity(0.035),
                  CupertinoColors.black.withOpacity(0.04),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentPrimary.withOpacity(0.18),
                        border: Border.all(
                            color: CupertinoColors.white.withOpacity(0.10)),
                      ),
                      child: const Icon(
                        CupertinoIcons.sparkles,
                        color: AppColors.accentPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.captionSmall11.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Yuk, kita coba ke sini.',
                            style: AppTypography.textRegular13.copyWith(
                              color: AppColors.textPrimary.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      minSize: 34,
                      padding: EdgeInsets.zero,
                      onPressed: onClose,
                      child: const Icon(
                        CupertinoIcons.xmark,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  destination.name,
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _InfoPill(label: category)),
                    const SizedBox(width: 8),
                    _InfoPill(
                        label:
                            'rating ${destination.rating.toStringAsFixed(1)}'),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textRegular13.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.accentPrimary,
                        onPressed: onOpen,
                        child: Text(
                          'Lihat Tempat',
                          style: AppTypography.textMedium15.copyWith(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: CupertinoColors.white.withOpacity(0.06),
        border: Border.all(color: CupertinoColors.white.withOpacity(0.08)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.captionSmall11.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
