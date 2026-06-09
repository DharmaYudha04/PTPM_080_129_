import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Set `--dart-define=JOGJA_REAL_GLASS=true` for the full BackdropFilter look.
///
/// The default keeps the same translucent glass aesthetic with a gradient,
/// border, and shadow, but avoids real-time backdrop blur on older devices.
const bool _kUseRealGlassByDefault = bool.fromEnvironment(
  'JOGJA_REAL_GLASS',
  defaultValue: false,
);

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.blur = 24,
    this.opacity = 0.08,
    this.borderRadius = AppSpacing.cardRadius,
    this.borderColor = AppColors.glassBorder,
    this.padding = const EdgeInsets.all(AppSpacing.spaceSM),
    this.width,
    this.height,
    this.color,
    this.enableRealBlur,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Color? color;

  /// Overrides the global glass mode for cards that truly need live blur.
  ///
  /// Leave null to follow `JOGJA_REAL_GLASS`. Use false for repeated cards in
  /// scrollable lists so they stay cheap to paint on older devices.
  final bool? enableRealBlur;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final effectiveOpacity = opacity.clamp(0.0, 1.0).toDouble();

    final content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: (color ?? CupertinoColors.white).withOpacity(effectiveOpacity),
        borderRadius: radius,
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: -6,
            color: Color(0x55000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00FFFFFF),
                    AppColors.glassHighlight,
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );

    final shouldUseRealBlur =
        (enableRealBlur ?? _kUseRealGlassByDefault) &&
        blur > 0 &&
        !MediaQuery.disableAnimationsOf(context);

    if (!shouldUseRealBlur) {
      return ClipRRect(
        borderRadius: radius,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );
  }
}
