import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'glass_card.dart';

class BottomSheetWrapper extends StatelessWidget {
  const BottomSheetWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        child: GlassCard(
          borderRadius: AppSpacing.sheetRadius,
          color: AppColors.backgroundSecondary,
          opacity: 0.86,
          child: child,
        ),
      ),
    );
  }
}
