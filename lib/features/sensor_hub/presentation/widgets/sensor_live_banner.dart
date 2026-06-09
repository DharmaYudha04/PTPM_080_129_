import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';

class SensorLiveBanner extends StatelessWidget {
  const SensorLiveBanner({
    required this.accel,
    required this.gyro,
    required this.live,
    super.key,
  });

  final String accel;
  final String gyro;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.078,
      borderRadius: 28,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.15,
            colors: [
              AppColors.accentTertiary.withOpacity(0.14),
              CupertinoColors.white.withOpacity(0.038),
              CupertinoColors.black.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentTertiary.withOpacity(0.14),
                    border: Border.all(
                      color: CupertinoColors.white.withOpacity(0.08),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.device_phone_portrait,
                    size: 22,
                    color: AppColors.accentTertiary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        live ? 'Motion sensors active' : 'Sensor preview mode',
                        style: AppTypography.displaySemi20.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.45,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'X / Y / Z realtime values',
                        style: AppTypography.captionSmall11.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _SensorLine(
              label: 'Accelerometer',
              value: accel,
              icon: CupertinoIcons.waveform_path_ecg,
            ),
            const SizedBox(height: 9),
            _SensorLine(
              label: 'Gyroscope',
              value: gyro,
              icon: CupertinoIcons.scope,
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorLine extends StatelessWidget {
  const _SensorLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: CupertinoColors.white.withOpacity(0.052),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.07),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 9),
          Flexible(
            flex: 4,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 5,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
