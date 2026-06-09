import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../notifications/notification_service.dart';
import '../../../shared/models/destination.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _prefs = prefs;

  static const _pendingFavoritesKey = 'pending_favorite_actions_v1';

  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  Box<DestinationModel> get _box =>
      Hive.box<DestinationModel>(AppConstants.destinationsBox);

  List<DestinationModel> getFavorites() {
    return _box.values.where((item) => item.isFavorite).toList();
  }

  Future<List<DestinationModel>> fetchFavorites() async {
    await syncPendingActions();
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/me/favorites');
      final favorites = (response.data ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map((item) => DestinationModel.fromApiJson(item).copyWith(isFavorite: true))
          .toList();

      for (final favorite in favorites) {
        await _box.put(
          favorite.id,
          favorite.copyWith(isFavorite: true),
        );
      }
      return getFavorites();
    } catch (_) {
      return getFavorites();
    }
  }

  Future<void> toggleFavorite(DestinationModel destination) async {
    final nextValue = !isFavorite(destination.id, fallback: destination.isFavorite);
    await setFavorite(destination.id, nextValue, destination: destination);
  }

  Future<void> setFavorite(
    String id,
    bool value, {
    DestinationModel? destination,
  }) async {
    final current = _box.get(id) ?? destination;
    if (current != null) {
      await _box.put(id, current.copyWith(isFavorite: value));
      if (value) {
        try {
          await getIt<NotificationService>().showImmediate(
            '${current.name} tersimpan di Favorit',
            'Monggo cek lagi saat kamu siap jalan-jalan.',
            payload: NotificationPayload.favorites,
          );
        } catch (_) {
          // Notifikasi bersifat tambahan. Favorit tetap harus berjalan.
        }
      }
    }

    try {
      if (value) {
        await _apiClient.dio.post('/me/favorites/$id');
      } else {
        await _apiClient.dio.delete('/me/favorites/$id');
      }
      await _removePending(id);
    } catch (_) {
      // Prioritaskan pengalaman pengguna: ikon dan daftar favorit tetap berubah
      // secara lokal. Aksi akan dicoba ulang saat fetch/sync berikutnya.
      await _savePending(id, value);
      return;
    }
  }

  bool isFavorite(String id, {bool fallback = false}) {
    final item = _box.get(id);
    return item?.isFavorite ?? fallback;
  }

  Future<void> syncPendingActions() async {
    final pending = _pendingActions();
    if (pending.isEmpty) return;

    final synced = <String>[];
    for (final entry in pending.entries) {
      try {
        if (entry.value) {
          await _apiClient.dio.post('/me/favorites/${entry.key}');
        } else {
          await _apiClient.dio.delete('/me/favorites/${entry.key}');
        }
        synced.add(entry.key);
      } catch (_) {
        // Jangan hentikan aplikasi hanya karena server sedang tidak tersedia.
      }
    }

    if (synced.isNotEmpty) {
      final next = _pendingActions()..removeWhere((key, value) => synced.contains(key));
      await _writePending(next);
    }
  }

  Map<String, bool> _pendingActions() {
    final raw = _prefs.getString(_pendingFavoritesKey);
    if (raw == null || raw.isEmpty) return <String, bool>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, bool>{};
    return decoded.map((key, value) => MapEntry(key.toString(), value == true));
  }

  Future<void> _savePending(String id, bool value) async {
    final pending = _pendingActions()..[id] = value;
    await _writePending(pending);
  }

  Future<void> _removePending(String id) async {
    final pending = _pendingActions()..remove(id);
    await _writePending(pending);
  }

  Future<void> _writePending(Map<String, bool> pending) async {
    if (pending.isEmpty) {
      await _prefs.remove(_pendingFavoritesKey);
    } else {
      await _prefs.setString(_pendingFavoritesKey, jsonEncode(pending));
    }
  }
}
