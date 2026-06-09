import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/destination_display_util.dart';
import '../../core/utils/destination_image_resolver.dart';
import '../models/destination.dart';
import 'glass_card.dart';

class DestinationCardCompact extends StatelessWidget {
  const DestinationCardCompact({
    required this.destination,
    required this.subtitle,
    required this.onTap,
    super.key,
    this.onFavoriteToggle,
  });

  final DestinationModel destination;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final safeImageUrl = DestinationImageResolver.resolve(destination);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: 0.78,
      onPressed: onTap,
      child: GlassCard(
        blur: 28,
        opacity: 0.075,
        borderRadius: 22,
        borderColor: CupertinoColors.white.withOpacity(0.12),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _CompactDestinationImage(
                imageUrl: safeImageUrl,
                destination: destination,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textMedium15.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textRegular13.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (onFavoriteToggle != null) ...[
              _CompactFavoriteButton(
                active: destination.isFavorite,
                onTap: onFavoriteToggle!,
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactDestinationImage extends StatelessWidget {
  const _CompactDestinationImage({
    required this.imageUrl,
    required this.destination,
  });

  final String imageUrl;
  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _CompactImageFallback(destination: destination);
    }
    if (DestinationImageResolver.isAsset(imageUrl)) {
      return Image.asset(
        imageUrl,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
        cacheWidth: 148,
        cacheHeight: 148,
        errorBuilder: (context, error, stackTrace) =>
            _CompactImageFallback(destination: destination),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 74,
      height: 74,
      fit: BoxFit.cover,
      memCacheWidth: 148,
      memCacheHeight: 148,
      maxWidthDiskCache: 148,
      maxHeightDiskCache: 148,
      errorWidget: (context, url, error) =>
          _CompactImageFallback(destination: destination),
    );
  }
}

class _CompactImageFallback extends StatelessWidget {
  const _CompactImageFallback({required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    final label = DestinationDisplayUtil.categoryFor(destination);
    final icon = _iconForCategory(label);

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentSecondary.withOpacity(0.26),
            AppColors.accentPrimary.withOpacity(0.20),
            AppColors.accentTertiary.withOpacity(0.14),
          ],
        ),
      ),
      child:
          Icon(icon, color: AppColors.textPrimary.withOpacity(0.72), size: 25),
    );
  }
}

class _CompactFavoriteButton extends StatefulWidget {
  const _CompactFavoriteButton({
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  State<_CompactFavoriteButton> createState() => _CompactFavoriteButtonState();
}

class _CompactFavoriteButtonState extends State<_CompactFavoriteButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
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
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.active
                ? CupertinoColors.systemPink.withOpacity(0.16)
                : CupertinoColors.white.withOpacity(0.075),
            border: Border.all(
              color: widget.active
                  ? CupertinoColors.systemPink.withOpacity(0.36)
                  : CupertinoColors.white.withOpacity(0.11),
            ),
          ),
          child: Icon(
            widget.active ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            size: 18,
            color: widget.active
                ? CupertinoColors.systemPink
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

IconData _iconForCategory(String category) {
  final value = category.toLowerCase();
  if (value.contains('kuliner')) return material.Icons.restaurant_rounded;
  if (value.contains('alam')) return CupertinoIcons.leaf_arrow_circlepath;
  if (value.contains('sejarah')) return CupertinoIcons.book_fill;
  if (value.contains('budaya')) return CupertinoIcons.book_fill;
  if (value.contains('seni')) return CupertinoIcons.paintbrush_fill;
  if (value.contains('belanja')) return CupertinoIcons.bag_fill;
  if (value.contains('aktivitas')) return CupertinoIcons.bolt_fill;
  if (value.contains('foto')) return CupertinoIcons.camera_fill;
  return CupertinoIcons.map_fill;
}
