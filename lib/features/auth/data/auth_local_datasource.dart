import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/user.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
    required ApiClient apiClient,
  })  : _secureStorage = secureStorage,
        _prefs = prefs,
        _apiClient = apiClient;

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  final ApiClient _apiClient;

  Future<UserModel> register(String name, String email, String password) async {
    _validateRegistration(name, email, password);
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'fullName': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      return _persistAuthResponse(response.data ?? <String, dynamic>{});
    } catch (error) {
      throw AppException(humanizeError(_unwrap(error)));
    }
  }

  Future<UserModel> login(String email, String password) async {
    _validateLogin(email, password);
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      return _persistAuthResponse(response.data ?? <String, dynamic>{});
    } catch (error) {
      throw AppException(humanizeError(_unwrap(error)));
    }
  }

  Future<bool> checkSession() async {
    final token = await _secureStorage.read(key: ApiConstants.authTokenKey);
    if (token == null || token.isEmpty) return false;

    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/auth/me');
      final user =
          _mapApiUser(_extractUser(response.data ?? <String, dynamic>{}));
      await _saveCurrentUser(user);
      return true;
    } catch (error) {
      final unwrapped = _unwrap(error);
      if (_isUnauthorized(unwrapped)) {
        await clearAuthSession(preserveBiometricUser: false);
        return false;
      }

      // Backend/jaringan bermasalah tidak boleh memaksa logout.
      // Kalau token masih tersimpan dan user lokal ada, biarkan sesi tetap terbuka.
      return await currentUser() != null;
    }
  }

  Future<UserModel?> currentUser() async {
    final email = _prefs.getString(AppConstants.currentUserKey);
    if (email == null) return null;
    return Hive.box<UserModel>(AppConstants.usersBox).get(email);
  }

  Future<void> logout() async {
    final preserveBiometricUser = await isBiometricEnabled();
    if (preserveBiometricUser &&
        await hasStoredToken() &&
        !await hasBiometricSession()) {
      await storeActiveSessionForBiometric();
    }
    await clearAuthSession(preserveBiometricUser: preserveBiometricUser);
  }

  Future<void> clearAuthSession({required bool preserveBiometricUser}) async {
    _apiClient.clearTokenCache();
    await _secureStorage.delete(key: ApiConstants.authTokenKey);
    await _secureStorage.delete(key: AppConstants.sessionKey);
    await _secureStorage.delete(key: AppConstants.sessionHashKey);
    await _secureStorage.delete(key: AppConstants.sessionUserKey);
    await _secureStorage.delete(key: AppConstants.sessionExpiryKey);
    if (!preserveBiometricUser) {
      await _secureStorage.delete(key: AppConstants.biometricAuthTokenKey);
      await _prefs.remove(AppConstants.biometricEnabledKey);
      await _prefs.remove(AppConstants.currentUserKey);
    }
  }

  Future<bool> hasStoredToken() async {
    final token = await _secureStorage.read(key: ApiConstants.authTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<bool> isBiometricEnabled() async {
    return _prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      await storeActiveSessionForBiometric();
    } else {
      await _secureStorage.delete(key: AppConstants.biometricAuthTokenKey);
    }
    await _prefs.setBool(AppConstants.biometricEnabledKey, enabled);
  }

  Future<bool> hasBiometricSession() async {
    final token =
        await _secureStorage.read(key: AppConstants.biometricAuthTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> storeActiveSessionForBiometric() async {
    final token = await _secureStorage.read(key: ApiConstants.authTokenKey);
    if (token == null || token.isEmpty) {
      throw const AppException(
        'Sesi login tidak ditemukan. Silakan masuk ulang sebelum mengaktifkan biometrik.',
      );
    }
    await _secureStorage.write(
      key: AppConstants.biometricAuthTokenKey,
      value: token,
    );
  }

  Future<UserModel?> restoreSessionWithBiometric() async {
    if (!await isBiometricEnabled()) return null;
    var token = await _secureStorage.read(key: ApiConstants.authTokenKey);
    token ??= await _secureStorage.read(
      key: AppConstants.biometricAuthTokenKey,
    );
    if (token == null || token.isEmpty) return null;

    await _secureStorage.write(key: ApiConstants.authTokenKey, value: token);
    _apiClient.updateToken(token);
    final valid = await checkSession();
    if (!valid) return null;
    return currentUser();
  }

  Future<UserModel> _persistAuthResponse(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const AppException('Token login tidak diterima dari backend.');
    }
    await _secureStorage.write(key: ApiConstants.authTokenKey, value: token);
    _apiClient.updateToken(token);
    final user = _mapApiUser(_extractUser(data));
    await _saveCurrentUser(user);
    return user;
  }

  Future<void> _saveCurrentUser(UserModel user) async {
    await Hive.box<UserModel>(AppConstants.usersBox).put(user.email, user);
    await _prefs.setString(AppConstants.currentUserKey, user.email);
  }

  Map<String, dynamic> _extractUser(Map<String, dynamic> json) {
    final nested = json['user'];
    if (nested is Map<String, dynamic>) return nested;
    return json;
  }

  UserModel _mapApiUser(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final id = json['id']?.toString();
    final email = json['email']?.toString();
    if (id == null || id.isEmpty || email == null || email.isEmpty) {
      throw const AppException('Data pengguna dari backend tidak lengkap.');
    }

    return UserModel(
      id: id,
      name: profile?['fullName']?.toString() ??
          json['name']?.toString() ??
          'Pengguna',
      email: email,
      joinedAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      quizBestScore: _toInt(json['quizBestScore']),
      visitedCount: _toInt(json['visitedCount']),
    );
  }

  int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _isUnauthorized(Object error) {
    if (error is AppException) {
      return error.statusCode == 401 || error.statusCode == 403;
    }
    if (error is DioException) {
      final status = error.response?.statusCode;
      return status == 401 || status == 403;
    }
    return false;
  }

  Object _unwrap(Object error) {
    if (error is DioException && error.error != null) return error.error!;
    return error;
  }

  void _validateRegistration(String name, String email, String password) {
    if (name.trim().length < 2) {
      throw const AppException('Nama minimal 2 karakter.');
    }
    _validateLogin(email, password);
    if (password.length < 8) {
      throw const AppException('Password minimal 8 karakter.');
    }
  }

  void _validateLogin(String email, String password) {
    if (!email.contains('@')) throw const AppException('Email tidak valid.');
    if (password.isEmpty) throw const AppException('Password wajib diisi.');
  }
}
