import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_local_datasource.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/favorites/data/favorites_local_datasource.dart';
import '../../features/guide/data/ai_remote_datasource.dart';
import '../../features/home/data/weather_remote_datasource.dart';
import '../../features/explore/data/destinations_remote_datasource.dart';
import '../../features/mini_game/data/quiz_remote_datasource.dart';
import '../network/api_client.dart';
import '../../features/notifications/notification_service.dart';
import '../services/location_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SharedPreferences>()) return;

  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<Dio>(Dio())
    ..registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage())
    ..registerLazySingleton<LocalAuthentication>(() => LocalAuthentication())
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(dio: getIt(), secureStorage: getIt()),
    )
    ..registerLazySingleton<LocationService>(() => const LocationService())
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(
          secureStorage: getIt(), prefs: getIt(), apiClient: getIt()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton<WeatherRemoteDataSource>(
      () => WeatherRemoteDataSource(
        dio: Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 12),
            sendTimeout: const Duration(seconds: 12),
            headers: const {'Accept': 'application/json'},
          ),
        ),
        prefs: getIt(),
      ),
    )
    ..registerLazySingleton<AiRemoteDataSource>(
      () => AiRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSource(apiClient: getIt(), prefs: getIt()),
    )
    ..registerLazySingleton<DestinationsRemoteDataSource>(
      () => DestinationsRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<QuizRemoteDataSource>(
        () => QuizRemoteDataSource(getIt()))
    ..registerLazySingleton<NotificationService>(() => NotificationService());
}
