import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_large.dart';
import '../../../favorites/data/favorites_local_datasource.dart';
import '../../../home/presentation/home_controller.dart';
import '../explore_controller.dart';

class DestinationGrid extends ConsumerWidget {
  const DestinationGrid({
    required this.items,
    required this.distanceLabels,
    super.key,
  });

  final List<DestinationModel> items;
  final Map<String, String> distanceLabels;

  Future<void> _toggleFavorite(
    WidgetRef ref,
    DestinationModel destination,
  ) async {
    await getIt<FavoritesLocalDataSource>().toggleFavorite(destination);

    ref.invalidate(exploreResultsProvider);
    ref.invalidate(featuredDestinationsProvider);
    ref.invalidate(nearbyDestinationsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 240,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final destination = items[index];

        return DestinationCardLarge(
          destination: destination,
          distanceLabel: distanceLabels[destination.id] ??
              '${destination.rating.toStringAsFixed(1)} ★',
          onTap: () =>
              context.push('${RouteNames.destination}/${destination.id}'),
          onFavoriteToggle: () => _toggleFavorite(ref, destination),
        );
      },
    );
  }
}