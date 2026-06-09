import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../shared/models/destination.dart';
import '../shared/models/user.dart';

class QuizScoreModel {
  QuizScoreModel({
    required this.id,
    required this.score,
    required this.correct,
    required this.total,
    required this.playedAt,
  });

  final String id;
  final int score;
  final int correct;
  final int total;
  final DateTime playedAt;
}

class QuizScoreAdapter extends TypeAdapter<QuizScoreModel> {
  @override
  final int typeId = 2;

  @override
  QuizScoreModel read(BinaryReader reader) {
    return QuizScoreModel(
      id: reader.readString(),
      score: reader.readInt(),
      correct: reader.readInt(),
      total: reader.readInt(),
      playedAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, QuizScoreModel obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.score)
      ..writeInt(obj.correct)
      ..writeInt(obj.total)
      ..writeString(obj.playedAt.toIso8601String());
  }
}

abstract final class HiveInit {
  static const _secureStorage = FlutterSecureStorage();
  static const _hiveKeyStorageKey = 'hive_aes_key';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DestinationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(QuizScoreAdapter());
    }

    final cipher = HiveAesCipher(await _readOrCreateHiveKey());

    await _openEncryptedBox<UserModel>(AppConstants.usersBox, cipher);
    await _openEncryptedBox<DestinationModel>(
      AppConstants.destinationsBox,
      cipher,
    );
    await _openEncryptedBox<QuizScoreModel>(
      AppConstants.quizScoresBox,
      cipher,
    );
  }

  static Future<List<int>> _readOrCreateHiveKey() async {
    final stored = await _secureStorage.read(key: _hiveKeyStorageKey);
    if (stored != null) return base64Url.decode(stored);

    final random = Random.secure();
    final key = List<int>.generate(32, (_) => random.nextInt(256));
    await _secureStorage.write(
      key: _hiveKeyStorageKey,
      value: base64UrlEncode(key),
    );
    return key;
  }

  static Future<Box<T>> _openEncryptedBox<T>(
    String name,
    HiveCipher cipher,
  ) async {
    try {
      return await Hive.openBox<T>(name, encryptionCipher: cipher);
    } catch (_) {
      await Hive.deleteBoxFromDisk(name);
      return Hive.openBox<T>(name, encryptionCipher: cipher);
    }
  }
}
