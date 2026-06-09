import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/destination_card_compact.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/favorites_local_datasource.dart';
import '../../../shared/widgets/jogja_page_header.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesLocalDataSource _favoritesDataSource;
  late Future<List<DestinationModel>> _favoritesFuture;

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  @override
  void initState() {
    super.initState();
    _favoritesDataSource = getIt<FavoritesLocalDataSource>();
    _favoritesFuture = _favoritesDataSource.fetchFavorites();
  }

  Future<void> _refresh() async {
    setState(() {
      _favoritesFuture = _favoritesDataSource.fetchFavorites();
    });
    await _favoritesFuture;
  }

  Future<void> _removeFavorite(DestinationModel destination) async {
    HapticFeedback.selectionClick();
    await _favoritesDataSource.setFavorite(destination.id, false, destination: destination);
    if (!mounted) return;
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgBottom,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.18,
            colors: [
              Color(0xFF282836),
              _bgTop,
              _bgMid,
              _bgBottom,
            ],
            stops: [0, 0.32, 0.68, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<List<DestinationModel>>(
            future: _favoritesFuture,
            builder: (context, snapshot) {
              final favorites = snapshot.data ?? _favoritesDataSource.getFavorites();
              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverRefreshControl(onRefresh: _refresh),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 126),
                    sliver: SliverList.list(
                      children: [
                        JogjaPageHeader(title: 'Favorit', subtitle: 'Tempat incaranmu tersimpan di sini.'),
                        const SizedBox(height: 18),
                        if (snapshot.connectionState == ConnectionState.waiting && favorites.isEmpty)
                          const Center(child: CupertinoActivityIndicator())
                        else if (favorites.isEmpty)
                          const _EmptyFavoritesCard()
                        else ...[
                          _FavoritesSummary(count: favorites.length),
                          const SizedBox(height: 16),
                          Text(
                            'Tempat Tersimpan',
                            style: AppTypography.displaySemi20.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.45,
                            ),
                          ),
                          const SizedBox(height: 11),
                          ...favorites.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) async {
                                  await _removeFavorite(item);
                                  return false;
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    color: CupertinoColors.systemRed.withOpacity(0.18),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.delete,
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                                child: DestinationCardCompact(
                                  destination: item,
                                  subtitle:
                                      '${item.category} • rating ${item.rating.toStringAsFixed(1)}',
                                  onTap: () {
                                    context.push('${RouteNames.destination}/${item.id}');
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentPrimary.withOpacity(0.14),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.10),
            ),
          ),
          child: const Icon(
            CupertinoIcons.heart_fill,
            size: 21,
            color: AppColors.accentPrimary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favorit',
                style: AppTypography.displayBold34.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  letterSpacing: -1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count == 0
                    ? 'Destinasi pilihanmu akan muncul di sini.'
                    : '$count destinasi tersimpan dan disinkronkan.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textRegular13.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FavoritesSummary extends StatelessWidget {
  const _FavoritesSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.078,
      borderRadius: 28,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
        child: Row(
          children: [
            const Icon(CupertinoIcons.check_mark_circled_solid, color: AppColors.accentPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count destinasi siap kamu kunjungi kembali.',
                style: AppTypography.textMedium15.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavoritesCard extends StatelessWidget {
  const _EmptyFavoritesCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 28,
      opacity: 0.075,
      borderRadius: 28,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      child: Column(
        children: [
          const Icon(CupertinoIcons.heart, size: 34, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Belum ada favorit',
            style: AppTypography.displaySemi20.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Ketuk ikon hati pada destinasi untuk menyimpannya.',
            textAlign: TextAlign.center,
            style: AppTypography.textRegular13.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
