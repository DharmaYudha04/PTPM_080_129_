import 'package:flutter/widgets.dart';

abstract final class ImageDecodeUtil {
  static int widthForLogicalSize(
    BuildContext context,
    double logicalWidth, {
    int min = 96,
    int max = 1080,
  }) {
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
    return (logicalWidth * dpr).round().clamp(min, max).toInt();
  }

  static int fullWidth(
    BuildContext context, {
    int min = 360,
    int max = 1080,
  }) {
    final width = MediaQuery.maybeSizeOf(context)?.width ?? 390;
    return widthForLogicalSize(context, width, min: min, max: max);
  }
}
