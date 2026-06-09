import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/weather_remote_datasource.dart';

class WeatherBanner extends StatelessWidget {
  const WeatherBanner({required this.weather, super.key});

  final WeatherModel weather;

  String _uvLabel(double value) {
    if (value <= 0) {
      return DateTime.now().hour >= 18 || DateTime.now().hour < 6
          ? 'Malam'
          : '1.0 Rendah';
    }
    if (value < 3) return '${value.toStringAsFixed(1)} Rendah';
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final temp = weather.temp.toStringAsFixed(0);
    final condition = weather.condition.trim();

    return GlassCard(
      blur: 34,
      opacity: 0.075,
      borderRadius: 28,
      borderColor: CupertinoColors.white.withOpacity(0.13),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.15,
                  colors: [
                    AppColors.accentTertiary.withOpacity(0.16),
                    CupertinoColors.white.withOpacity(0.045),
                    CupertinoColors.black.withOpacity(0.015),
                  ],
                  stops: const [0, 0.48, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 24,
            right: 24,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.white.withOpacity(0),
                    CupertinoColors.white.withOpacity(0.46),
                    CupertinoColors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _WeatherIcon(condition: condition),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelMedium12.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weather.isStale
                                ? '$condition • data cache'
                                : condition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textRegular13.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$temp°',
                      style: AppTypography.displayBold34.copyWith(
                        fontSize: 42,
                        height: 1,
                        letterSpacing: -1.8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _WeatherMetric(
                        icon: CupertinoIcons.drop_fill,
                        label: 'Kelembapan',
                        value: '${weather.humidity}%',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _WeatherMetric(
                        icon: CupertinoIcons.wind,
                        label: 'Angin',
                        value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _WeatherMetric(
                        icon: CupertinoIcons.sun_max_fill,
                        label: 'UV',
                        value: _uvLabel(weather.uvIndex),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.condition});

  final String condition;

  @override
  Widget build(BuildContext context) {
    final lower = condition.toLowerCase();

    final icon = lower.contains('hujan') || lower.contains('rain')
        ? CupertinoIcons.cloud_rain_fill
        : lower.contains('awan') || lower.contains('cloud')
            ? CupertinoIcons.cloud_sun_fill
            : lower.contains('cerah') || lower.contains('clear')
                ? CupertinoIcons.sun_max_fill
                : CupertinoIcons.cloud_sun_fill;

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentTertiary.withOpacity(0.14),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.09),
        ),
      ),
      child: Icon(
        icon,
        size: 25,
        color: AppColors.accentTertiary,
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: CupertinoColors.white.withOpacity(0.055),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.075),
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
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSmall11.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textMedium15.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.15,
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
