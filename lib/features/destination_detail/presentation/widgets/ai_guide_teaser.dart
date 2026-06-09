import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';

class AIGuideTeaser extends StatefulWidget {
  const AIGuideTeaser({
    required this.destinationName,
    super.key,
  });

  final String destinationName;

  @override
  State<AIGuideTeaser> createState() => _AIGuideTeaserState();
}

class _AIGuideTeaserState extends State<AIGuideTeaser> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        HapticFeedback.selectionClick();
        final prompt = Uri.encodeQueryComponent(
          'Ceritakan tentang ${widget.destinationName} dan buatkan itinerary singkat.',
        );
        final destination = Uri.encodeQueryComponent(widget.destinationName);
        context.go('${RouteNames.guide}?prompt=$prompt&destination=$destination');
      },
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          blur: 32,
          opacity: 0.078,
          borderRadius: 24,
          borderColor: CupertinoColors.white.withOpacity(0.13),
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.15,
                colors: [
                  AppColors.accentSecondary.withOpacity(0.14),
                  CupertinoColors.white.withOpacity(0.035),
                  CupertinoColors.black.withOpacity(0.02),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentSecondary.withOpacity(0.15),
                    border: Border.all(
                      color: CupertinoColors.white.withOpacity(0.08),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.sparkles,
                    size: 20,
                    color: AppColors.accentSecondary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    'Tanya Kanca Jogja tentang tempat ini',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textRegular13.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: AppColors.accentPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
