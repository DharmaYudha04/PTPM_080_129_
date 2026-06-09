import 'package:flutter/cupertino.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static const cupertinoTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.accentPrimary,
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    barBackgroundColor: AppColors.backgroundPrimary,
    textTheme: CupertinoTextThemeData(
      textStyle: AppTypography.textRegular17,
      navLargeTitleTextStyle: AppTypography.displayBold34,
      navTitleTextStyle: AppTypography.textMedium15,
      actionTextStyle: AppTypography.textMedium15,
      tabLabelTextStyle: AppTypography.captionSmall11,
    ),
  );

  static CupertinoThemeData theme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: AppColors.accentPrimary,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundPrimary : AppColors.backgroundWarm,
      barBackgroundColor:
          isDark ? AppColors.backgroundPrimary : AppColors.surfaceWarm,
      textTheme: CupertinoTextThemeData(
        textStyle: AppTypography.textRegular17.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.textDark,
        ),
        navLargeTitleTextStyle: AppTypography.displayBold34.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.textDark,
        ),
        navTitleTextStyle: AppTypography.textMedium15.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.textDark,
        ),
        actionTextStyle: AppTypography.textMedium15.copyWith(
          color: AppColors.accentPrimary,
        ),
        tabLabelTextStyle: AppTypography.captionSmall11,
      ),
    );
  }
}
