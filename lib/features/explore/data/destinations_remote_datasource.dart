import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/destination.dart';

class DestinationsRemoteDataSource {
  DestinationsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<DestinationModel>> fetchDestinations({
    String? search,
    String? type,
    String? category,
    String? tag,
  }) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/destinations',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
          if (category != null && category.trim().isNotEmpty) 'category': category.trim(),
          if (tag != null && tag.trim().isNotEmpty) 'tag': tag.trim(),
        },
        options: Options(responseType: ResponseType.json),
      );

      final items = (response.data ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(DestinationModel.fromApiJson)
          .toList();

      return syncLocalCache(items);
    } catch (error) {
      final cached = Hive.box<DestinationModel>(AppConstants.destinationsBox).values.toList();
      if (cached.isNotEmpty) return cached;
      throw AppException(humanizeError(error));
    }
  }

  Future<DestinationModel> fetchDestinationDetail(String idOrSlug) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/destinations/$idOrSlug',
        options: Options(responseType: ResponseType.json),
      );
      final destination = DestinationModel.fromApiJson(response.data ?? <String, dynamic>{});
      await upsertLocal(destination);
      return destination;
    } catch (error) {
      final cached = getCachedDestination(idOrSlug);
      if (cached != null) return cached;
      throw AppException(humanizeError(error));
    }
  }

  List<DestinationModel> cachedSimilar(DestinationModel destination, {int limit = 3}) {
    final box = Hive.box<DestinationModel>(AppConstants.destinationsBox);
    return box.values
        .where((item) => item.id != destination.id && item.category == destination.category)
        .take(limit)
        .toList();
  }

  DestinationModel? getCachedDestination(String idOrSlug) {
    final box = Hive.box<DestinationModel>(AppConstants.destinationsBox);
    final byId = box.get(idOrSlug);
    if (byId != null) return byId;
    for (final item in box.values) {
      if (item.slug == idOrSlug) return item;
    }
    return null;
  }

  Future<void> upsertLocal(DestinationModel item) async {
    final box = Hive.box<DestinationModel>(AppConstants.destinationsBox);
    final existing = box.get(item.id);
    await box.put(
      item.id,
      item.copyWith(
        isFavorite: item.isFavorite || (existing?.isFavorite ?? false),
      ),
    );
  }

  Future<List<DestinationModel>> syncLocalCache(List<DestinationModel> items) async {
    final box = Hive.box<DestinationModel>(AppConstants.destinationsBox);
    final favoriteIds = box.values
        .where((item) => item.isFavorite)
        .map((item) => item.id)
        .toSet();

    final merged = <DestinationModel>[];
    final updates = <String, DestinationModel>{};

    for (final destination in items) {
      final existing = box.get(destination.id);
      final isFavorite = destination.isFavorite ||
          favoriteIds.contains(destination.id) ||
          (existing?.isFavorite ?? false);
      final mergedDestination = destination.copyWith(isFavorite: isFavorite);

      updates[destination.id] = mergedDestination;
      merged.add(mergedDestination);
    }

    if (updates.isNotEmpty) {
      await box.putAll(updates);
    }

    return merged;
  }
}
