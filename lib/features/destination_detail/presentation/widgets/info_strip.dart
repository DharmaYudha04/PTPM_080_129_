import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/destination_display_util.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/glass_card.dart';

class InfoStrip extends StatelessWidget {
  const InfoStrip({
    required this.destination,
    super.key,
  });

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: CupertinoIcons.clock,
            label: 'Jam Buka',
            value:
                DestinationDisplayUtil.compactOpenHours(destination.openHours),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: CupertinoIcons.money_dollar,
            label: 'Tiket',
            value: DestinationDisplayUtil.compactPrice(destination.ticketPrice),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: CupertinoIcons.location_solid,
            label: 'Durasi',
            value: destination.recommendedDuration.trim().isEmpty
                ? 'Cek waktu'
                : destination.recommendedDuration,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.074,
      borderRadius: 22,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: EdgeInsets.zero,
      child: Container(
        height: 104,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.accentPrimary,
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
