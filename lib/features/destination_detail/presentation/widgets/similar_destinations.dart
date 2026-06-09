import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/utils/destination_display_util.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_compact.dart';

class SimilarDestinations extends StatelessWidget {
  const SimilarDestinations({required this.items, super.key});

  final List<DestinationModel> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final destination = items[index];
          return SizedBox(
            width: 280,
            child: DestinationCardCompact(
              destination: destination,
              subtitle: DestinationDisplayUtil.categoryFor(destination),
              onTap: () => context.go('${RouteNames.destination}/${destination.id}'),
            ),
          );
        },
      ),
    );
  }
}
