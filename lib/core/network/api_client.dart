import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../errors/app_error.dart';

class ApiClient {
  ApiClient({required Dio dio, required FlutterSecureStorage secureStorage})
      : _dio = dio,
        _secureStorage = secureStorage {
    _dio.options.baseUrl = ApiConstants.backendBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _token();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.reject(
            error.copyWith(error: ApiErrorMapper.fromDio(error)),
          );
        },
      ),
    );
  }

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  String? _cachedToken;
  bool _tokenLoaded = false;

  Dio get dio => _dio;

  Future<String?> _token() async {
    if (_tokenLoaded) return _cachedToken;
    _cachedToken = await _secureStorage.read(key: ApiConstants.authTokenKey);
    _tokenLoaded = true;
    return _cachedToken;
  }

  void updateToken(String? token) {
    _cachedToken = token;
    _tokenLoaded = true;
  }

  void clearTokenCache() {
    updateToken(null);
  }

  bool isAuthFailure(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      return status == 401 || status == 403;
    }
    if (error is AppException) {
      return error.statusCode == 401 || error.statusCode == 403;
    }
    return false;
  }
}
