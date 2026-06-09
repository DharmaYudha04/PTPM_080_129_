import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

class WeatherModel {
  WeatherModel({
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.locationLabel,
    this.isStale = false,
    this.isLocationFallback = false,
    this.locationAccuracyMeters,
    this.latitude,
    this.longitude,
  });

  final double temp;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double uvIndex;
  final String locationLabel;
  final bool isStale;
  final bool isLocationFallback;
  final double? locationAccuracyMeters;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
        'temp': temp,
        'condition': condition,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'uvIndex': uvIndex,
        'locationLabel': locationLabel,
        'isLocationFallback': isLocationFallback,
        'locationAccuracyMeters': locationAccuracyMeters,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory WeatherModel.fromJson(
    Map<String, dynamic> json, {
    bool isStale = false,
  }) {
    return WeatherModel(
      temp: (json['temp'] as num?)?.toDouble() ?? 0,
      condition: json['condition']?.toString() ?? 'Cuaca Jogja',
      humidity: (json['humidity'] as num?)?.round() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0,
      locationLabel:
          json['locationLabel']?.toString() ?? 'Kota Yogyakarta, DI Yogyakarta',
      isStale: isStale,
      isLocationFallback: json['isLocationFallback'] as bool? ?? false,
      locationAccuracyMeters:
          (json['locationAccuracyMeters'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  factory WeatherModel.unavailable({
    String locationLabel = 'Jogja fallback • aktifkan lokasi',
    bool isLocationFallback = true,
    double? latitude,
    double? longitude,
    double? locationAccuracyMeters,
  }) =>
      WeatherModel(
        temp: 27,
        condition: 'Cuaca belum tersinkron',
        humidity: 70,
        windSpeed: 1.8,
        uvIndex: 4.0,
        locationLabel: locationLabel,
        isStale: true,
        isLocationFallback: isLocationFallback,
        locationAccuracyMeters: locationAccuracyMeters,
        latitude: latitude,
        longitude: longitude,
      );
}

class WeatherRemoteDataSource {
  WeatherRemoteDataSource({required Dio dio, required SharedPreferences prefs})
      : _dio = dio,
        _prefs = prefs;

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';
  static const _weatherTimeout = Duration(seconds: 12);

  Future<WeatherModel> fetchWeather({
    double lat = -7.7971,
    double lon = 110.3708,
    bool isLocationFallback = false,
    double? locationAccuracyMeters,
  }) async {
    final cacheKey = _cacheKey(AppConstants.weatherCacheKey, lat, lon);
    final cacheTimeKey = _cacheKey(AppConstants.weatherCacheTimeKey, lat, lon);
    final cached = _prefs.getString(cacheKey);
    final cachedAt = _prefs.getInt(cacheTimeKey);
    final hasFreshCache = cached != null &&
        cachedAt != null &&
        DateTime.now().millisecondsSinceEpoch - cachedAt <
            const Duration(minutes: 30).inMilliseconds;

    if (hasFreshCache) {
      final cachedWeather = _decodeCachedWeather(cached);
      if (cachedWeather != null &&
          cachedWeather.isLocationFallback == isLocationFallback) {
        return cachedWeather;
      }
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _openMeteoUrl,
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current':
              'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'hourly': 'uv_index',
          'forecast_days': 1,
          'timezone': 'auto',
          'wind_speed_unit': 'ms',
        },
        options: Options(
          responseType: ResponseType.json,
          connectTimeout: _weatherTimeout,
          receiveTimeout: _weatherTimeout,
          sendTimeout: _weatherTimeout,
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      final current =
          data['current'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final hourly =
          data['hourly'] as Map<String, dynamic>? ?? <String, dynamic>{};
      if (current['temperature_2m'] == null) {
        throw const FormatException('Weather payload missing current data');
      }
      final currentTime = DateTime.tryParse(current['time']?.toString() ?? '');
      final uvIndex = _currentUvIndex(hourly, referenceTime: currentTime);

      final weather = WeatherModel(
        temp: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
        condition:
            _conditionFromCode((current['weather_code'] as num?)?.toInt()),
        humidity: (current['relative_humidity_2m'] as num?)?.round() ?? 0,
        windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        uvIndex: uvIndex,
        locationLabel: _locationLabel(
          lat,
          lon,
          isLocationFallback: isLocationFallback,
          locationAccuracyMeters: locationAccuracyMeters,
        ),
        isLocationFallback: isLocationFallback,
        locationAccuracyMeters: locationAccuracyMeters,
        latitude: lat,
        longitude: lon,
      );

      await _prefs.setString(cacheKey, jsonEncode(weather.toJson()));
      await _prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      return weather;
    } catch (_) {
      final cachedWeather = _decodeCachedWeather(cached, isStale: true);
      if (cachedWeather != null &&
          cachedWeather.isLocationFallback == isLocationFallback) {
        return cachedWeather;
      }

      return WeatherModel.unavailable(
        locationLabel: _locationLabel(
          lat,
          lon,
          isLocationFallback: isLocationFallback,
          locationAccuracyMeters: locationAccuracyMeters,
        ),
        isLocationFallback: isLocationFallback,
        latitude: lat,
        longitude: lon,
        locationAccuracyMeters: locationAccuracyMeters,
      );
    }
  }

  String _cacheKey(String baseKey, double lat, double lon) {
    return '${baseKey}_area_v2_${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}';
  }

  WeatherModel? _decodeCachedWeather(String? payload, {bool isStale = false}) {
    if (payload == null || payload.isEmpty) return null;

    try {
      return WeatherModel.fromJson(
        jsonDecode(payload) as Map<String, dynamic>,
        isStale: isStale,
      );
    } catch (_) {
      return null;
    }
  }

  double _currentUvIndex(
    Map<String, dynamic> hourly, {
    DateTime? referenceTime,
  }) {
    final values = hourly['uv_index'] as List<dynamic>? ?? const <dynamic>[];
    final now = referenceTime ?? DateTime.now();
    if (values.isEmpty) return _estimatedUvIndex(now);

    final times = hourly['time'] as List<dynamic>? ?? const <dynamic>[];
    var index = now.hour.clamp(0, values.length - 1).toInt();
    if (times.isNotEmpty && times.length == values.length) {
      for (var i = 0; i < times.length; i++) {
        final parsed = DateTime.tryParse(times[i].toString());
        if (parsed != null &&
            parsed.year == now.year &&
            parsed.month == now.month &&
            parsed.day == now.day &&
            parsed.hour == now.hour) {
          index = i;
          break;
        }
      }
    }

    final raw = (values[index] as num?)?.toDouble() ?? 0.0;
    if (raw > 0) return raw;
    return _estimatedUvIndex(now);
  }

  double _estimatedUvIndex(DateTime referenceTime) {
    final hour = referenceTime.hour;
    if (hour < 6 || hour >= 18) return 0.0;
    if (hour < 9 || hour >= 16) return 1.0;
    if (hour < 11 || hour >= 14) return 3.0;
    return 5.0;
  }

  String _locationLabel(
    double lat,
    double lon, {
    required bool isLocationFallback,
    double? locationAccuracyMeters,
  }) {
    if (isLocationFallback) return 'Jogja fallback • aktifkan lokasi';

    final accuracy = _accuracyLabel(locationAccuracyMeters);
    final area = _knownJogjaArea(lat, lon);

    if (area != null) {
      return accuracy == null ? area : '$area • $accuracy';
    }

    final coordinate = '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
    return accuracy == null
        ? 'Lokasi perangkat • $coordinate'
        : 'Lokasi perangkat • $coordinate • $accuracy';
  }

  String? _knownJogjaArea(double lat, double lon) {
    if (lat < -8.25 || lat > -7.45 || lon < 109.85 || lon > 110.85) {
      return null;
    }

    if (lat >= -7.80 && lat <= -7.73 && lon >= 110.36 && lon <= 110.44) {
      if (lon >= 110.415 && lat >= -7.77) {
        return 'Maguwoharjo, Depok, Sleman';
      }
      if (lon >= 110.385) {
        return 'Caturtunggal, Depok, Sleman';
      }
      return 'Depok, Sleman, DI Yogyakarta';
    }

    if (lat >= -7.86 && lat <= -7.72 && lon >= 110.32 && lon <= 110.43) {
      if (lat < -7.83 && lon < 110.39) {
        return 'Sewon, Bantul, DI Yogyakarta';
      }
      if (lat <= -7.79 && lon > 110.39) {
        return 'Banguntapan, Bantul, DI Yogyakarta';
      }
      if (lat > -7.79) {
        return 'Depok, Sleman, DI Yogyakarta';
      }
      return 'Kota Yogyakarta, DI Yogyakarta';
    }
    if (lat > -7.75 && lon >= 110.30 && lon <= 110.45) {
      return 'Sleman, DI Yogyakarta';
    }
    if (lat < -7.86 && lon >= 110.25 && lon <= 110.45) {
      return 'Bantul, DI Yogyakarta';
    }
    if (lon < 110.25) return 'Kulon Progo, DI Yogyakarta';
    if (lon > 110.45) return 'Gunungkidul, DI Yogyakarta';
    return 'DI Yogyakarta';
  }

  String? _accuracyLabel(double? meters) {
    if (meters == null || meters <= 0) return null;
    if (meters >= 1000) {
      return '±${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '±${meters.round()} m';
  }

  String _conditionFromCode(int? code) {
    switch (code) {
      case 0:
        return 'Cerah, enak buat jalan-jalan';
      case 1:
      case 2:
        return 'Cerah berawan';
      case 3:
        return 'Berawan';
      case 45:
      case 48:
        return 'Berkabut tipis';
      case 51:
      case 53:
      case 55:
        return 'Gerimis ringan';
      case 61:
      case 63:
      case 65:
        return 'Hujan, siapkan payung';
      case 80:
      case 81:
      case 82:
        return 'Hujan lokal';
      case 95:
      case 96:
      case 99:
        return 'Hujan petir';
      default:
        return 'Cuaca Jogja terkini';
    }
  }
}
