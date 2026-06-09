import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/destination_display_util.dart';
import '../../core/utils/destination_image_resolver.dart';
import '../../core/utils/image_decode_util.dart';
import '../models/destination.dart';
import 'glass_card.dart';

class DestinationCardLarge extends StatefulWidget {
  const DestinationCardLarge({
    required this.destination,
    required this.onTap,
    required this.onFavoriteToggle,
    super.key,
    this.distanceLabel,
  });

  final DestinationModel destination;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final String? distanceLabel;

  @override
  State<DestinationCardLarge> createState() => _DestinationCardLargeState();
}

class _DestinationCardLargeState extends State<DestinationCardLarge> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final safeImageUrl = DestinationImageResolver.resolve(destination);

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
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Stack(
            children: [
              Positioned.fill(
                child: _DestinationCoverImage(
                  imageUrl: safeImageUrl,
                  destination: destination,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        CupertinoColors.black.withOpacity(0.05),
                        CupertinoColors.black.withOpacity(0.12),
                        CupertinoColors.black.withOpacity(0.78),
                      ],
                      stops: const [0, 0.42, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: _RatingPill(
                  label: widget.distanceLabel ?? '${destination.rating} ★',
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: _FavoriteButton(
                  active: destination.isFavorite,
                  onTap: widget.onFavoriteToggle,
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: GlassCard(
                  blur: 30,
                  opacity: 0.085,
                  borderRadius: 22,
                  borderColor: CupertinoColors.white.withOpacity(0.13),
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: RadialGradient(
                              center: Alignment.topLeft,
                              radius: 1.2,
                              colors: [
                                CupertinoColors.white.withOpacity(0.10),
                                CupertinoColors.white.withOpacity(0.035),
                                CupertinoColors.black.withOpacity(0.02),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destination.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.displaySemi20.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.45,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MiniPill(
                                          icon: CupertinoIcons.tag_fill,
                                          label: DestinationDisplayUtil
                                              .categoryFor(
                                            destination,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: _MiniPill(
                                          icon: CupertinoIcons.clock_fill,
                                          label: DestinationDisplayUtil
                                              .compactOpenHours(
                                                  destination.openHours),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.white.withOpacity(0.08),
                                border: Border.all(
                                  color:
                                      CupertinoColors.white.withOpacity(0.10),
                                ),
                              ),
                              child: const Icon(
                                CupertinoIcons.chevron_right,
                                size: 17,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
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
    );
  }
}

class _DestinationCoverImage extends StatelessWidget {
  const _DestinationCoverImage({
    required this.imageUrl,
    required this.destination,
  });

  final String imageUrl;
  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    final decodeWidth = ImageDecodeUtil.fullWidth(
      context,
      min: 540,
      max: 980,
    );

    if (imageUrl.isEmpty) {
      return _DestinationImageFallback(destination: destination);
    }
    if (DestinationImageResolver.isAsset(imageUrl)) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        cacheWidth: decodeWidth,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            _DestinationImageFallback(destination: destination),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      memCacheWidth: decodeWidth,
      maxWidthDiskCache: decodeWidth,
      filterQuality: FilterQuality.medium,
      placeholder: (context, url) => Container(
        color: CupertinoColors.white.withOpacity(0.05),
      ),
      errorWidget: (context, url, error) =>
          _DestinationImageFallback(destination: destination),
    );
  }
}

class _DestinationImageFallback extends StatelessWidget {
  const _DestinationImageFallback({required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    final label = DestinationDisplayUtil.categoryFor(destination);
    final icon = _iconForCategory(label);
    final initials = destination.name.trim().isEmpty
        ? 'JG'
        : destination.name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((word) => word.isEmpty ? '' : word[0].toUpperCase())
            .join();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentSecondary.withOpacity(0.32),
            AppColors.accentPrimary.withOpacity(0.22),
            AppColors.accentTertiary.withOpacity(0.14),
            CupertinoColors.black.withOpacity(0.12),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 38,
            right: 34,
            child: Icon(
              icon,
              size: 70,
              color: CupertinoColors.white.withOpacity(0.12),
            ),
          ),
          Positioned(
            left: 22,
            top: 48,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white.withOpacity(0.10),
                border:
                    Border.all(color: CupertinoColors.white.withOpacity(0.12)),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.7,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            top: 128,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textPrimary.withOpacity(0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForCategory(String category) {
  final value = category.toLowerCase();
  if (value.contains('budaya')) return CupertinoIcons.book_fill;
  if (value.contains('sejarah')) return CupertinoIcons.book_fill;
  if (value.contains('alam')) return CupertinoIcons.leaf_arrow_circlepath;
  if (value.contains('kuliner')) return material.Icons.restaurant_rounded;
  if (value.contains('belanja')) return CupertinoIcons.bag_fill;
  if (value.contains('seni')) return CupertinoIcons.paintbrush_fill;
  if (value.contains('aktivitas')) return CupertinoIcons.bolt_fill;
  if (value.contains('foto')) return CupertinoIcons.camera_fill;
  return CupertinoIcons.map_fill;
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 24,
      opacity: 0.10,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.13),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label.toLowerCase().contains('km') ||
                    label.toLowerCase().contains('m')
                ? CupertinoIcons.location_solid
                : CupertinoIcons.star_fill,
            size: 12,
            color: AppColors.accentTertiary,
          ),
          const SizedBox(width: 5),
          Text(
            label.replaceAll('★', '').trim(),
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
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
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          width: 38,
          height: 38,
          blur: 24,
          opacity: widget.active ? 0.16 : 0.10,
          borderRadius: 999,
          borderColor: widget.active
              ? CupertinoColors.systemPink.withOpacity(0.36)
              : CupertinoColors.white.withOpacity(0.13),
          padding: EdgeInsets.zero,
          child: Center(
            child: Transform.translate(
              offset: const Offset(0.5, 0),
              child: Icon(
                widget.active
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                size: 19,
                color: widget.active
                    ? CupertinoColors.systemPink
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: CupertinoColors.white.withOpacity(0.065),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.075),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
