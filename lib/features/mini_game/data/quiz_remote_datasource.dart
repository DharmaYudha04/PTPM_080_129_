import 'package:hive/hive.dart';

import '../../../bootstrap/hive_init.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.category,
  });

  final String id;
  final String question;
  final List<QuizOption> options;
  final String category;
}

class QuizOption {
  QuizOption({required this.id, required this.text});

  final String id;
  final String text;
}

class QuizSession {
  QuizSession({
    required this.attemptId,
    required this.timeLimitSeconds,
    required this.questions,
  });

  final String attemptId;
  final int timeLimitSeconds;
  final List<QuizQuestion> questions;
}

class QuizAnswerPayload {
  QuizAnswerPayload({
    required this.questionId,
    required this.selectedOptionId,
    required this.timeTakenSeconds,
  });

  final String questionId;
  final String selectedOptionId;
  final int timeTakenSeconds;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'timeTakenSeconds': timeTakenSeconds,
      };
}


class QuizSubmitResult {
  QuizSubmitResult({
    required this.score,
    required this.correct,
    required this.total,
  });

  final int score;
  final int correct;
  final int total;
}

class QuizRemoteDataSource {
  QuizRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<QuizSession> start({int totalQuestions = 5}) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/quiz/start',
      data: {'totalQuestions': totalQuestions},
    );
    final data = response.data ?? <String, dynamic>{};
    final questions = (data['questions'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) {
      final map = item as Map<String, dynamic>;
      final options = (map['options'] as List<dynamic>? ?? const <dynamic>[])
          .map((option) {
        final optionMap = option as Map<String, dynamic>;
        return QuizOption(
          id: optionMap['id'] as String,
          text: _readableOptionText(optionMap['optionText'] as String),
        );
      }).toList();
      return QuizQuestion(
        id: map['id'] as String,
        question: map['questionText'] as String,
        category: map['category'] as String? ?? 'Umum',
        options: options,
      );
    }).toList();

    return QuizSession(
      attemptId: data['attemptId'] as String,
      timeLimitSeconds: data['timeLimitSeconds'] as int? ?? 60,
      questions: questions,
    );
  }

  Future<QuizSubmitResult> submit({
    required String attemptId,
    required List<QuizAnswerPayload> answers,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/quiz/submit',
      data: {
        'attemptId': attemptId,
        'answers': answers.map((answer) => answer.toJson()).toList(),
      },
    );
    final attempt = response.data?['attempt'] as Map<String, dynamic>?;
    final score = attempt?['totalScore'] as int? ?? 0;
    final correct = attempt?['correctAnswers'] as int? ?? 0;
    final total = attempt?['totalQuestions'] as int? ?? answers.length;
    await saveScore(score: score, correct: correct, total: total);
    return QuizSubmitResult(score: score, correct: correct, total: total);
  }

  Future<void> saveScore({
    required int score,
    required int correct,
    required int total,
  }) async {
    final box = Hive.box<QuizScoreModel>(AppConstants.quizScoresBox);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await box.put(
      id,
      QuizScoreModel(
        id: id,
        score: score,
        correct: correct,
        total: total,
        playedAt: DateTime.now(),
      ),
    );
  }
}


String _readableOptionText(String value) {
  final text = value.trim();
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
