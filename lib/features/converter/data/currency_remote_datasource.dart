import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';

class CurrencyRatesResult {
  const CurrencyRatesResult({
    required this.rates,
    required this.updatedAt,
    required this.nextUpdateAt,
    required this.sourceName,
    required this.fromFallback,
    required this.fromCache,
  });

  final Map<String, double> rates;
  final DateTime? updatedAt;
  final DateTime? nextUpdateAt;
  final String sourceName;
  final bool fromFallback;
  final bool fromCache;
}

class CurrencyRemoteDataSource {
  CurrencyRemoteDataSource({
    required Dio dio,
    required SharedPreferences prefs,
  })  : _dio = dio,
        _prefs = prefs;

  final Dio _dio;
  final SharedPreferences _prefs;

  Future<CurrencyRatesResult> fetchRates({bool forceRefresh = false}) async {
    final cached = _readCachedResult();

    if (!forceRefresh && cached != null && _cacheStillCurrent(cached)) {
      return cached;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.currencyBaseUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      final result = data['result']?.toString().toLowerCase();
      if (result == 'error') {
        throw FormatException(
          data['error-type']?.toString() ?? 'Currency API returned error',
        );
      }

      final rawRates = data['conversion_rates'] ?? data['rates'];
      if (rawRates is! Map) {
        throw const FormatException('Currency response does not contain rates');
      }

      final rates = <String, double>{};
      for (final entry in rawRates.entries) {
        final code = entry.key.toString().trim().toUpperCase();
        final value = entry.value;
        if (code.length != 3 || value is! num || value <= 0) continue;
        rates[code] = value.toDouble();
      }

      // Endpoint memakai USD sebagai base, pastikan USD tetap tersedia.
      rates['USD'] = rates['USD'] ?? 1;
      if (!rates.containsKey('IDR')) {
        throw const FormatException('IDR rate not found');
      }

      final sortedRates = Map.fromEntries(
        rates.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );

      final resultData = CurrencyRatesResult(
        rates: sortedRates,
        updatedAt:
            _unixToDateTime(data['time_last_update_unix']) ?? DateTime.now(),
        nextUpdateAt: _unixToDateTime(data['time_next_update_unix']),
        sourceName: _sourceName(data['provider']),
        fromFallback: false,
        fromCache: false,
      );
      await _writeCache(resultData);
      return resultData;
    } catch (_) {
      // Kalau API gagal tapi ada cache lama, tetap pakai cache lama.
      if (cached != null) {
        return CurrencyRatesResult(
          rates: cached.rates,
          updatedAt: cached.updatedAt,
          nextUpdateAt: cached.nextUpdateAt,
          sourceName: cached.sourceName,
          fromFallback: cached.fromFallback,
          fromCache: true,
        );
      }

      // Fallback hanya untuk mode offline pertama kali. Nilai ini bukan sumber utama.
      final fallback = <String, double>{
        'AUD': 1.52,
        'CAD': 1.36,
        'CHF': 0.91,
        'CNY': 7.20,
        'EUR': 0.92,
        'GBP': 0.79,
        'IDR': 16000,
        'JPY': 150.0,
        'KRW': 1330.0,
        'MYR': 4.70,
        'SAR': 3.75,
        'SGD': 1.35,
        'THB': 36.0,
        'USD': 1,
      };
      final resultData = CurrencyRatesResult(
        rates: fallback,
        updatedAt: DateTime.now(),
        nextUpdateAt: DateTime.now().add(const Duration(hours: 1)),
        sourceName: 'Offline fallback',
        fromFallback: true,
        fromCache: false,
      );
      await _writeCache(resultData);
      return resultData;
    }
  }

  CurrencyRatesResult? _readCachedResult() {
    final rates = _readCachedRates();
    if (rates == null || rates.length <= 10) return null;

    final updatedAt = _millisToDateTime(
      _prefs.getInt(AppConstants.currencyCacheUpdatedAtKey),
    );
    final nextUpdateAt = _millisToDateTime(
      _prefs.getInt(AppConstants.currencyCacheNextUpdateKey),
    );

    return CurrencyRatesResult(
      rates: rates,
      updatedAt: updatedAt ??
          _millisToDateTime(_prefs.getInt(AppConstants.currencyCacheTimeKey)),
      nextUpdateAt: nextUpdateAt,
      sourceName: _prefs.getString(AppConstants.currencyCacheSourceKey) ??
          'ExchangeRate-API',
      fromFallback:
          _prefs.getBool(AppConstants.currencyCacheFallbackKey) ?? false,
      fromCache: true,
    );
  }

  Map<String, double>? _readCachedRates() {
    final cached = _prefs.getString(AppConstants.currencyCacheKey);
    if (cached == null) return null;

    try {
      final decoded = jsonDecode(cached);
      if (decoded is! Map) return null;

      final rates = <String, double>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! num || value <= 0) continue;
        rates[entry.key.toString().toUpperCase()] = value.toDouble();
      }
      return rates;
    } catch (_) {
      return null;
    }
  }

  bool _cacheStillCurrent(CurrencyRatesResult cached) {
    if (cached.fromFallback) return false;

    final now = DateTime.now();
    final nextUpdateAt = cached.nextUpdateAt;
    if (nextUpdateAt != null) {
      return now.isBefore(nextUpdateAt);
    }

    final cachedAt = _millisToDateTime(
      _prefs.getInt(AppConstants.currencyCacheTimeKey),
    );
    if (cachedAt == null) return false;
    return now.difference(cachedAt) < const Duration(hours: 1);
  }

  Future<void> _writeCache(CurrencyRatesResult result) async {
    await _prefs.setString(
      AppConstants.currencyCacheKey,
      jsonEncode(result.rates),
    );
    await _prefs.setInt(
      AppConstants.currencyCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    if (result.updatedAt != null) {
      await _prefs.setInt(
        AppConstants.currencyCacheUpdatedAtKey,
        result.updatedAt!.millisecondsSinceEpoch,
      );
    } else {
      await _prefs.remove(AppConstants.currencyCacheUpdatedAtKey);
    }
    if (result.nextUpdateAt != null) {
      await _prefs.setInt(
        AppConstants.currencyCacheNextUpdateKey,
        result.nextUpdateAt!.millisecondsSinceEpoch,
      );
    } else {
      await _prefs.remove(AppConstants.currencyCacheNextUpdateKey);
    }
    await _prefs.setString(
      AppConstants.currencyCacheSourceKey,
      result.sourceName,
    );
    await _prefs.setBool(
      AppConstants.currencyCacheFallbackKey,
      result.fromFallback,
    );
  }

  DateTime? _unixToDateTime(Object? value) {
    if (value is int && value > 0) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true)
          .toLocal();
    }
    if (value is num && value > 0) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt() * 1000,
        isUtc: true,
      ).toLocal();
    }
    return null;
  }

  DateTime? _millisToDateTime(int? value) {
    if (value == null || value <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  String _sourceName(Object? provider) {
    final value = provider?.toString().trim();
    if (value == null || value.isEmpty) return 'ExchangeRate-API';
    if (value.contains('exchangerate-api.com')) return 'ExchangeRate-API';
    return value;
  }
}
