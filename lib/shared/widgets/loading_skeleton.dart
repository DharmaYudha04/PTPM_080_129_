import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundSecondary,
      highlightColor: AppColors.textTertiary,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
