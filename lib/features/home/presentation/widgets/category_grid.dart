import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/explore/presentation/explore_controller.dart';
import '../../../../shared/models/category.dart';
import '../../../../shared/widgets/glass_card.dart';

class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const items = [
      CategoryModel(
          label: 'Budaya',
          icon: CupertinoIcons.book_fill,
          color: AppColors.accentSecondary),
      CategoryModel(
          label: 'Alam',
          icon: CupertinoIcons.leaf_arrow_circlepath,
          color: AppColors.accentTertiary),
      CategoryModel(
          label: 'Kuliner',
          icon: material.Icons.restaurant_rounded,
          color: AppColors.accentPrimary),
      CategoryModel(
          label: 'Belanja',
          icon: CupertinoIcons.bag_fill,
          color: AppColors.textSecondary),
      CategoryModel(
          label: 'Seni',
          icon: CupertinoIcons.paintbrush_fill,
          color: AppColors.textSecondary),
      CategoryModel(
          label: 'Aktivitas',
          icon: CupertinoIcons.bolt_fill,
          color: AppColors.textSecondary),
      CategoryModel(
          label: 'Sejarah',
          icon: CupertinoIcons.map_fill,
          color: AppColors.accentSecondary),
      CategoryModel(
          label: 'Foto',
          icon: CupertinoIcons.camera_fill,
          color: AppColors.accentTertiary),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 260 ? 2 : (width < 360 ? 3 : 4);

        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return _LiquidCategoryTile(
              item: item,
              onTap: () {
                ref.read(activeCategoryProvider.notifier).state = item.label;
                ref.read(searchQueryProvider.notifier).state = '';
                context.go(RouteNames.explore);
              },
            );
          },
        );
      },
    );
  }
}

class _LiquidCategoryTile extends StatefulWidget {
  const _LiquidCategoryTile({
    required this.item,
    required this.onTap,
  });

  final CategoryModel item;
  final VoidCallback onTap;

  @override
  State<_LiquidCategoryTile> createState() => _LiquidCategoryTileState();
}

class _LiquidCategoryTileState extends State<_LiquidCategoryTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: SizedBox.expand(
          child: GlassCard(
            blur: 30,
            opacity: _pressed ? 0.12 : 0.085,
            borderRadius: 18,
            borderColor:
                _pressed ? item.color.withOpacity(0.38) : AppColors.glassBorder,
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 0.9,
                        colors: [
                          item.color.withOpacity(_pressed ? 0.16 : 0.09),
                          CupertinoColors.white.withOpacity(0.015),
                          CupertinoColors.black.withOpacity(0.02),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.color.withOpacity(0.16),
                            border: Border.all(
                                color:
                                    CupertinoColors.white.withOpacity(0.055)),
                          ),
                          child: Center(
                              child:
                                  Icon(item.icon, color: item.color, size: 18)),
                        ),
                        const SizedBox(height: 7),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.label,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
