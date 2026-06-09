import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/models/destination.dart';
import '../data/home_repository_impl.dart';
import '../data/weather_remote_datasource.dart';
import '../../explore/data/destinations_remote_datasource.dart';

final _homeRepositoryProvider = Provider<HomeRepositoryImpl>(
  (ref) => HomeRepositoryImpl(
    getIt<WeatherRemoteDataSource>(),
    getIt<LocationService>(),
    getIt<DestinationsRemoteDataSource>(),
  ),
);

final weatherProvider = FutureProvider.autoDispose<WeatherModel>(
  (ref) => ref.read(_homeRepositoryProvider).getWeather(),
);

/// Satu sumber data destinasi untuk Home agar Featured dan Nearby tidak
/// melakukan fetch/cache-read berulang. Provider ini sengaja tidak autoDispose
/// supaya data tetap hangat saat user berpindah tab.
final homeDestinationsProvider = FutureProvider<List<DestinationModel>>((ref) {
  return ref.read(_homeRepositoryProvider).destinations();
});

final featuredDestinationsProvider = FutureProvider<List<DestinationModel>>((
  ref,
) async {
  final all = await ref.watch(homeDestinationsProvider.future);
  return all.take(3).toList();
});

final nearbyDestinationsProvider = FutureProvider<List<DestinationModel>>((
  ref,
) async {
  final all = await ref.watch(homeDestinationsProvider.future);
  final position = await getIt<LocationService>().getCurrentPositionOrNull();

  if (position == null) {
    return all.take(3).toList();
  }

  return getIt<LocationService>()
      .sortByDistance(
        destinations: all,
        userLat: position.latitude,
        userLon: position.longitude,
      )
      .take(3)
      .toList();
});

final destinationDistanceLabelProvider =
    FutureProvider.family.autoDispose<String, DestinationModel>((ref, item) {
  return ref.read(_homeRepositoryProvider).distanceLabelFor(item);
});
