import 'package:flutter/foundation.dart';

abstract final class EnvironmentConfig {
  static const _explicitBackendBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');
  static const _localServerIp = String.fromEnvironment('LOCAL_SERVER_IP');
  static const _backendPort = String.fromEnvironment('BACKEND_PORT', defaultValue: '3000');
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');

  static String get backendBaseUrl {
    if (_explicitBackendBaseUrl.trim().isNotEmpty) {
      return _normalize(_explicitBackendBaseUrl.trim());
    }

    if (_localServerIp.trim().isNotEmpty) {
      return _normalize('http://${_localServerIp.trim()}:$_backendPort/api');
    }

    if (kIsWeb) return 'http://localhost:$_backendPort/api';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$_backendPort/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost:$_backendPort/api';
      case TargetPlatform.fuchsia:
        return 'http://localhost:$_backendPort/api';
    }
  }

  static bool get isProduction => appEnv.toLowerCase() == 'production';

  static String _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) return trimmed.substring(0, trimmed.length - 1);
    return trimmed;
  }
}
