import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'glass_card.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          const SizedBox(width: 2),
          Icon(icon, color: AppColors.textPrimary, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.textMedium15,
          ),
        ),
        if (icon != null) const SizedBox(width: 2),
      ],
    );

    if (filled) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: AppColors.accentPrimary,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        onPressed: onPressed,
        child: child,
      );
    }

    return GestureDetector(
      onTap: onPressed,
      child: GlassCard(
        borderRadius: AppSpacing.pillRadius,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: child,
      ),
    );
  }
}
