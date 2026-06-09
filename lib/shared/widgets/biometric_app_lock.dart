import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/data/auth_local_datasource.dart';
import '../../features/auth/domain/usecases/biometric_usecase.dart';
import 'glass_card.dart';

class BiometricAppLock extends StatefulWidget {
  const BiometricAppLock({required this.child, super.key});

  final Widget child;

  @override
  State<BiometricAppLock> createState() => _BiometricAppLockState();
}

class _BiometricAppLockState extends State<BiometricAppLock>
    with WidgetsBindingObserver {
  final AuthLocalDataSource _authDataSource = getIt<AuthLocalDataSource>();
  final BiometricUseCase _biometricUseCase = BiometricUseCase(
    getIt<LocalAuthentication>(),
  );

  bool _checking = true;
  bool _locked = false;
  bool _authenticating = false;
  bool _unlockedForForeground = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateLock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _unlockedForForeground = false;
      return;
    }

    if (state == AppLifecycleState.resumed && !_authenticating) {
      _evaluateLock();
    }
  }

  Future<void> _evaluateLock() async {
    if (kIsWeb) {
      _finishUnlocked();
      return;
    }

    final shouldLock = await _shouldLock();
    if (!mounted) return;

    if (!shouldLock || _unlockedForForeground) {
      _finishUnlocked();
      return;
    }

    setState(() {
      _checking = false;
      _locked = true;
      _error = null;
    });
    await _authenticate();
  }

  Future<bool> _shouldLock() async {
    return await _authDataSource.isBiometricEnabled() &&
        await _authDataSource.hasStoredToken();
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;

    setState(() {
      _authenticating = true;
      _locked = true;
      _error = null;
    });

    final authorized = await _biometricUseCase();
    if (!mounted) return;

    if (authorized) {
      _unlockedForForeground = true;
      setState(() {
        _authenticating = false;
        _checking = false;
        _locked = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _authenticating = false;
      _checking = false;
      _locked = true;
      _error = 'Verifikasi biometrik dibutuhkan untuk membuka aplikasi.';
    });
  }

  Future<void> _usePassword() async {
    HapticFeedback.selectionClick();
    GoRouter? router;
    final routerContext = AppRouter.rootNavigatorKey.currentContext ?? context;
    try {
      router = GoRouter.of(routerContext);
    } catch (_) {
      router = null;
    }

    await _authDataSource.clearAuthSession(preserveBiometricUser: true);
    if (!mounted) return;

    _unlockedForForeground = false;
    setState(() {
      _checking = false;
      _locked = false;
      _authenticating = false;
      _error = null;
    });

    router?.go(RouteNames.auth);
  }

  void _finishUnlocked() {
    if (!mounted) return;
    setState(() {
      _checking = false;
      _locked = false;
      _authenticating = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || _locked) {
      return _BiometricLockScreen(
        authenticating: _authenticating || _checking,
        error: _error,
        onRetry: _authenticate,
        onUsePassword: _usePassword,
      );
    }

    return widget.child;
  }
}

class _BiometricLockScreen extends StatelessWidget {
  const _BiometricLockScreen({
    required this.authenticating,
    required this.error,
    required this.onRetry,
    required this.onUsePassword,
  });

  final bool authenticating;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onUsePassword;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF06070B),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.18,
            colors: [
              Color(0xFF282836),
              Color(0xFF181821),
              Color(0xFF0F0F16),
              Color(0xFF06070B),
            ],
            stops: [0, 0.32, 0.68, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: GlassCard(
                  blur: 34,
                  opacity: 0.075,
                  borderRadius: 28,
                  borderColor: CupertinoColors.white.withOpacity(0.12),
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentPrimary.withOpacity(0.16),
                          border: Border.all(
                            color: CupertinoColors.white.withOpacity(0.14),
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.lock_shield_fill,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'JogjaSplorasi terkunci',
                        textAlign: TextAlign.center,
                        style: AppTypography.displaySemi22.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error ??
                            'Gunakan fingerprint atau face unlock perangkat.',
                        textAlign: TextAlign.center,
                        style: AppTypography.textRegular13.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _LockButton(
                        label: authenticating
                            ? 'Memverifikasi...'
                            : 'Buka dengan Biometrik',
                        filled: true,
                        isLoading: authenticating,
                        onPressed: authenticating ? null : onRetry,
                      ),
                      const SizedBox(height: 10),
                      _LockButton(
                        label: 'Masuk dengan Password',
                        onPressed: authenticating ? null : onUsePassword,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LockButton extends StatelessWidget {
  const _LockButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onPressed,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          color: filled
              ? AppColors.accentPrimary.withOpacity(0.84)
              : CupertinoColors.white.withOpacity(0.06),
          border: Border.all(
            color: CupertinoColors.white.withOpacity(filled ? 0.18 : 0.10),
            width: 0.8,
          ),
        ),
        child: isLoading
            ? const CupertinoActivityIndicator(
                color: AppColors.textPrimary,
              )
            : Text(
                label,
                style: AppTypography.textMedium15.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
      ),
    );
  }
}
