import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricUseCase {
  const BiometricUseCase(this._localAuth);

  final LocalAuthentication _localAuth;

  Future<bool> call() async {
    if (kIsWeb) return false;
    try {
      final available = await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
      if (!available) return false;
      return _localAuth.authenticate(
        localizedReason: 'Buka JogjaSplorasi dengan biometrik perangkat',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
