import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'glass_card.dart';

class JogjaPageHeader extends StatelessWidget {
  const JogjaPageHeader({
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBack) ...[
          JogjaBackButton(onTap: () {
            HapticFeedback.selectionClick();
            if (onBack != null) {
              onBack!();
              return;
            }
            if (context.canPop()) {
              context.pop();
            }
          }),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.displayBold34.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  letterSpacing: -0.9,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class JogjaBackButton extends StatefulWidget {
  const JogjaBackButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  State<JogjaBackButton> createState() => _JogjaBackButtonState();
}

class _JogjaBackButtonState extends State<JogjaBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          width: 44,
          height: 44,
          blur: 28,
          opacity: 0.085,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.14),
          padding: EdgeInsets.zero,
          child: const Center(
            child: Icon(
              CupertinoIcons.chevron_left,
              size: 21,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
