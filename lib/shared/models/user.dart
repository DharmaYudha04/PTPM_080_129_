import 'package:hive/hive.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.joinedAt,
    this.quizBestScore = 0,
    this.visitedCount = 0,
  });

  final String id;
  final String name;
  final String email;
  final DateTime joinedAt;
  final int quizBestScore;
  final int visitedCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'joinedAt': joinedAt.toIso8601String(),
        'quizBestScore': quizBestScore,
        'visitedCount': visitedCount,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        quizBestScore: json['quizBestScore'] as int? ?? 0,
        visitedCount: json['visitedCount'] as int? ?? 0,
      );
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      id: reader.readString(),
      name: reader.readString(),
      email: reader.readString(),
      joinedAt: DateTime.parse(reader.readString()),
      quizBestScore: reader.readInt(),
      visitedCount: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.email)
      ..writeString(obj.joinedAt.toIso8601String())
      ..writeInt(obj.quizBestScore)
      ..writeInt(obj.visitedCount);
  }
}
