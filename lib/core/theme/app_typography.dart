import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const fallback = <String>[
    'Helvetica Neue',
    'sans-serif',
  ];

  static const displayBold34 = TextStyle(
    fontFamilyFallback: fallback,
    fontSize: 34,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static const displaySemi22 = TextStyle(
    fontFamilyFallback: fallback,
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const displaySemi20 = TextStyle(
    fontFamilyFallback: fallback,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const textRegular17 = TextStyle(
    fontFamilyFallback: fallback,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const textMedium15 = TextStyle(
    fontFamilyFallback: fallback,
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const textRegular13 = TextStyle(
    fontFamilyFallback: fallback,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const labelMedium12 = TextStyle(
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static const captionSmall11 = TextStyle(
    fontFamilyFallback: fallback,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
