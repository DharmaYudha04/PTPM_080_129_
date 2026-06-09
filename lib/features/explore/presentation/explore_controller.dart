import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/models/destination.dart';
import '../data/explore_repository_impl.dart';
import '../data/destinations_remote_datasource.dart';
import '../domain/usecases/filter_destinations_usecase.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final activeCategoryProvider = StateProvider<String?>((ref) => null);
final gridModeProvider = StateProvider<bool>((ref) => true);
final sortByNearestProvider = StateProvider<bool>((ref) => true);
final explorePageProvider = StateProvider<int>((ref) => 1);
final exploreResetSignalProvider = StateProvider<int>((ref) => 0);

final _repositoryProvider = Provider<ExploreRepositoryImpl>(
  (ref) => ExploreRepositoryImpl(getIt<DestinationsRemoteDataSource>()),
);

final exploreLocationProvider = FutureProvider.autoDispose<Position?>((ref) {
  return getIt<LocationService>().getCurrentPositionOrNull();
});

final exploreResultsProvider =
    FutureProvider.autoDispose<List<DestinationModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(activeCategoryProvider);
  final sortByNearest = ref.watch(sortByNearestProvider);
  final position = await ref.watch(exploreLocationProvider.future);

  final all = await ref.read(_repositoryProvider).all();

  final filtered = const FilterDestinationsUseCase().call(
    all,
    FilterModel(query: query, category: category),
  );

  if (!sortByNearest || position == null) return filtered;

  return getIt<LocationService>().sortByDistance(
    destinations: filtered,
    userLat: position.latitude,
    userLon: position.longitude,
  );
});
