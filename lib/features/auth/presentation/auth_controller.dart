import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/di/injection.dart';
import '../../../core/errors/app_error.dart';
import '../../../shared/models/user.dart';
import '../data/auth_local_datasource.dart';
import '../domain/usecases/biometric_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';

class AuthState {
  const AuthState({this.isLoading = false, this.user, this.error});

  final bool isLoading;
  final UserModel? user;
  final String? error;

  AuthState copyWith({bool? isLoading, UserModel? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController()
      : _loginUseCase = LoginUseCase(getIt()),
        _registerUseCase = RegisterUseCase(getIt()),
        _logoutUseCase = LogoutUseCase(getIt()),
        _biometricUseCase = BiometricUseCase(getIt<LocalAuthentication>()),
        _localDataSource = getIt<AuthLocalDataSource>(),
        super(const AuthState());

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final BiometricUseCase _biometricUseCase;
  final AuthLocalDataSource _localDataSource;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _loginUseCase(email, password);
      if (!await _confirmBiometricIfEnabled()) return;
      state = state.copyWith(isLoading: false, user: user);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: humanizeError(error));
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _registerUseCase(name, email, password);
      if (!await _confirmBiometricIfEnabled()) return;
      state = state.copyWith(isLoading: false, user: user);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: humanizeError(error));
    }
  }

  Future<bool> biometricLogin() async {
    if (!await _localDataSource.isBiometricEnabled()) {
      state = state.copyWith(
        error: 'Kunci aplikasi biometrik belum diaktifkan dari Profil.',
      );
      return false;
    }

    final authorized = await _biometricUseCase();
    if (!authorized) return false;
    final user = await _localDataSource.restoreSessionWithBiometric();
    if (user == null) {
      state = state.copyWith(
        error:
            'Sesi biometrik tidak valid atau sudah berakhir. Silakan masuk dengan email dan password.',
      );
      return false;
    }
    state = state.copyWith(user: user, error: null);
    return true;
  }

  Future<void> logout() => _logoutUseCase();

  Future<bool> _confirmBiometricIfEnabled() async {
    if (!await _localDataSource.isBiometricEnabled()) return true;

    final authorized = await _biometricUseCase();
    if (authorized) {
      await _localDataSource.storeActiveSessionForBiometric();
      return true;
    }

    await _localDataSource.clearAuthSession(preserveBiometricUser: true);
    state = state.copyWith(
      isLoading: false,
      error: 'Verifikasi biometrik dibutuhkan untuk masuk ke akun ini.',
    );
    return false;
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

final sessionProvider = FutureProvider<bool>(
  (ref) => getIt<AuthLocalDataSource>().checkSession(),
);
