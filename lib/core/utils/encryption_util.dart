import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

abstract final class EncryptionUtil {
  static final Random _random = Random.secure();

  static String generateSalt({int length = 16}) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hashPassword(String rawPassword, String salt) {
    final bytes = utf8.encode('$salt::$rawPassword');
    return sha256.convert(bytes).toString();
  }

  static String legacyHashPassword(String rawPassword) {
    return sha256.convert(utf8.encode(rawPassword)).toString();
  }

  static String hashSessionToken({
    required String token,
    required String email,
    required String expiry,
  }) {
    return sha256.convert(utf8.encode('$token::$email::$expiry')).toString();
  }

  static bool fixedTimeEquals(String left, String right) {
    if (left.length != right.length) return false;

    var diff = 0;
    for (var i = 0; i < left.length; i++) {
      diff |= left.codeUnitAt(i) ^ right.codeUnitAt(i);
    }
    return diff == 0;
  }
}
