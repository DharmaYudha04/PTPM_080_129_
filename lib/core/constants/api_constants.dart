import '../config/environment_config.dart';

abstract final class ApiConstants {
  static String get backendBaseUrl => EnvironmentConfig.backendBaseUrl;

  static const authTokenKey = 'auth_token';

  static const weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  static const currencyBaseCurrency = 'USD';

  /// ExchangeRate-API v6 endpoint.
  /// Jika CURRENCY_KEY kosong, aplikasi memakai open access endpoint tanpa key.
  static String get currencyBaseUrl {
    final key = currencyApiKey.trim();
    if (key.isEmpty) {
      return 'https://open.er-api.com/v6/latest/$currencyBaseCurrency';
    }
    return 'https://v6.exchangerate-api.com/v6/$key/latest/$currencyBaseCurrency';
  }

  static const aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://openrouter.ai/api',
  );

  static const weatherApiKey = String.fromEnvironment(
    'WEATHER_KEY',
    defaultValue: '',
  );

  static const currencyApiKey = String.fromEnvironment(
    'CURRENCY_KEY',
    defaultValue: '',
  );

  static const aiApiKey = String.fromEnvironment('AI_KEY', defaultValue: '');

  static const aiModel = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'openai/gpt-4o-mini',
  );
}
