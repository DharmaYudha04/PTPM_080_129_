import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill(
    this.label, {
    super.key,
    this.color = AppColors.accentSecondary,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall11.copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}
