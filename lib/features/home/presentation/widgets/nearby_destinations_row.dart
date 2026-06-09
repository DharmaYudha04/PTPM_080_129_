import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/utils/destination_display_util.dart';
import '../../../../shared/models/destination.dart';
import '../../../../shared/widgets/destination_card_compact.dart';
import '../home_controller.dart';

class NearbyDestinationsRow extends ConsumerWidget {
  const NearbyDestinationsRow({required this.destinations, super.key});

  final List<DestinationModel> destinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: destinations
          .map(
            (destination) {
              final distance = ref.watch(destinationDistanceLabelProvider(destination));
              final label = DestinationDisplayUtil.categoryFor(destination);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DestinationCardCompact(
                  destination: destination,
                  subtitle: distance.when(
                    data: (value) => '$value • $label',
                    loading: () => 'Menghitung jarak • $label',
                    error: (_, __) => '$label • rating ${destination.rating.toStringAsFixed(1)}',
                  ),
                  onTap: () => context.push('${RouteNames.destination}/${destination.id}'),
                ),
              );
            },
          )
          .toList(),
    );
  }

}