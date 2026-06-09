import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_large.dart';
import '../../../explore/presentation/explore_controller.dart';
import '../../../favorites/data/favorites_local_datasource.dart';
import '../home_controller.dart';

class FeaturedDestinationsRow extends ConsumerStatefulWidget {
  const FeaturedDestinationsRow({
    required this.destinations,
    super.key,
  });

  final List<DestinationModel> destinations;

  @override
  ConsumerState<FeaturedDestinationsRow> createState() =>
      _FeaturedDestinationsRowState();
}

class _FeaturedDestinationsRowState
    extends ConsumerState<FeaturedDestinationsRow> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      viewportFraction: 0.92,
    );
  }

  Future<void> _toggleFavorite(DestinationModel destination) async {
    await getIt<FavoritesLocalDataSource>().toggleFavorite(destination);

    ref.invalidate(featuredDestinationsProvider);
    ref.invalidate(nearbyDestinationsProvider);
    ref.invalidate(exploreResultsProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 248,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.destinations.length,
        itemBuilder: (context, index) {
          final destination = widget.destinations[index];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final page = _controller.hasClients
                  ? (_controller.page ?? _controller.initialPage.toDouble())
                  : _controller.initialPage.toDouble();
              final distance = (page - index).abs().clamp(0.0, 1.0);
              final scale = 1.0 - (distance * 0.055);
              final translateY = distance * 8;

              return Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                right: index == widget.destinations.length - 1 ? 0 : 12,
              ),
              child: DestinationCardLarge(
                destination: destination,
                distanceLabel: '${destination.rating} ★',
                onTap: () => context.push(
                  '${RouteNames.destination}/${destination.id}',
                ),
                onFavoriteToggle: () => _toggleFavorite(destination),
              ),
            ),
          );
        },
      ),
    );
  }
}
