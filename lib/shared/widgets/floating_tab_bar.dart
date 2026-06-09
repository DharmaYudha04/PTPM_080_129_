import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'glass_card.dart';

class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  /// Index:
  /// 0 = Home
  /// 1 = Explore
  /// 2 = Guide
  /// 3 = Profile
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _TabItem(
        label: 'Beranda',
        icon: CupertinoIcons.house,
        activeIcon: CupertinoIcons.house_fill,
      ),
      _TabItem(
        label: 'Jelajahi',
        icon: CupertinoIcons.map,
        activeIcon: CupertinoIcons.map_fill,
      ),
      _TabItem(
        label: 'Kanca',
        icon: CupertinoIcons.sparkles,
        activeIcon: CupertinoIcons.sparkles,
      ),
      _TabItem(
        label: 'Profil',
        icon: CupertinoIcons.person,
        activeIcon: CupertinoIcons.person_fill,
      ),
      _TabItem(
        label: 'TPM',
        icon: CupertinoIcons.doc_text,
        activeIcon: CupertinoIcons.doc_text_fill,
      ),
    ];

    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth =
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
              final barWidth = availableWidth.clamp(0.0, 410.0).toDouble();

              return RepaintBoundary(
                child: GlassCard(
                  width: barWidth,
                  height: 64,
                  blur: 20,
                  opacity: 0.082,
                  borderRadius: AppSpacing.tabBarRadius,
                  borderColor: CupertinoColors.white.withOpacity(0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final active = currentIndex == index;

                      return Expanded(
                        child: _LiquidTabItem(
                          item: item,
                          active: active,
                          onTap: () {
                            if (!kIsWeb) HapticFeedback.selectionClick();
                            onTap(index);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LiquidTabItem extends StatefulWidget {
  const _LiquidTabItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _TabItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_LiquidTabItem> createState() => _LiquidTabItemState();
}

class _LiquidTabItemState extends State<_LiquidTabItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final item = widget.item;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: active ? 1.08 : 1,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  active ? item.activeIcon : item.icon,
                  size: 21,
                  color: AppColors.textPrimary.withOpacity(active ? 1 : 0.48),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 10,
                  height: 1,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                  letterSpacing: -0.15,
                  color:
                      AppColors.textPrimary.withOpacity(active ? 0.95 : 0.42),
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
