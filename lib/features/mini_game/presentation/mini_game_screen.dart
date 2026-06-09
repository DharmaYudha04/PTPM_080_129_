import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../bootstrap/hive_init.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/quiz_remote_datasource.dart';
import 'widgets/quiz_timer_arc.dart';
import '../../../shared/widgets/jogja_page_header.dart';

enum QuizPhase { lobby, question, result }

class QuizState {
  const QuizState({
    this.phase = QuizPhase.lobby,
    this.questions = const [],
    this.questionIndex = 0,
    this.score = 0,
    this.timeLeft = 15,
    this.attemptId,
    this.answers = const [],
    this.isSubmitting = false,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.errorMessage,
  });

  final QuizPhase phase;
  final List<QuizQuestion> questions;
  final int questionIndex;
  final int score;
  final int timeLeft;
  final String? attemptId;
  final List<QuizAnswerPayload> answers;
  final bool isSubmitting;
  final int correctAnswers;
  final int totalQuestions;
  final String? errorMessage;

  QuizQuestion? get currentQuestion =>
      questionIndex < questions.length ? questions[questionIndex] : null;

  QuizState copyWith({
    QuizPhase? phase,
    List<QuizQuestion>? questions,
    int? questionIndex,
    int? score,
    int? timeLeft,
    String? attemptId,
    List<QuizAnswerPayload>? answers,
    bool? isSubmitting,
    int? correctAnswers,
    int? totalQuestions,
    String? errorMessage,
  }) {
    return QuizState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      questionIndex: questionIndex ?? this.questionIndex,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      attemptId: attemptId ?? this.attemptId,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      errorMessage: errorMessage,
    );
  }
}

class QuizController extends StateNotifier<QuizState> {
  QuizController(this._dataSource) : super(const QuizState());

  final QuizRemoteDataSource _dataSource;
  Timer? _timer;

  Future<void> start() async {
    _timer?.cancel();
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final session = await _dataSource.start(totalQuestions: 5);
      if (session.questions.isEmpty) {
        state = const QuizState(errorMessage: 'Soal kuis belum tersedia. Coba jalankan ulang data kuis terlebih dahulu.');
        return;
      }

      state = QuizState(
        phase: QuizPhase.question,
        questions: session.questions,
        timeLeft: 15,
        attemptId: session.attemptId,
      );
      _startTimer();
    } catch (_) {
      state = const QuizState(errorMessage: 'Kuis belum bisa dimulai. Coba cek koneksi dan masuk ulang.');
    }
  }

  Future<void> answer(int index) async {
    final current = state.currentQuestion;
    if (current == null || state.isSubmitting) return;
    if (index < 0 || index >= current.options.length) return;

    HapticFeedback.selectionClick();

    final option = current.options[index];
    final answer = QuizAnswerPayload(
      questionId: current.id,
      selectedOptionId: option.id,
      timeTakenSeconds: 15 - state.timeLeft,
    );

    await _advance([...state.answers, answer]);
  }

  Future<void> _advance(List<QuizAnswerPayload> answers) async {
    if (state.isSubmitting) return;

    if (state.questionIndex >= state.questions.length - 1) {
      await _finishQuiz(answers);
      return;
    }

    state = state.copyWith(
      questionIndex: state.questionIndex + 1,
      timeLeft: 15,
      answers: answers,
    );
  }

  Future<void> _finishQuiz(List<QuizAnswerPayload> answers) async {
    final attemptId = state.attemptId;
    if (attemptId == null) return;

    _timer?.cancel();

    state = state.copyWith(
      isSubmitting: true,
      timeLeft: 0,
      answers: answers,
    );

    try {
      final result = await _dataSource.submit(
        attemptId: attemptId,
        answers: answers,
      );

      state = state.copyWith(
        phase: QuizPhase.result,
        score: result.score,
        timeLeft: 0,
        answers: answers,
        isSubmitting: false,
        correctAnswers: result.correct,
        totalQuestions: result.total,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        phase: QuizPhase.lobby,
        isSubmitting: false,
        errorMessage: 'Jawaban belum bisa dikirim. Coba ulangi saat koneksi stabil.',
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != QuizPhase.question || state.isSubmitting) return;

      if (state.timeLeft <= 1) {
        _advance(state.answers);
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      }
    });
  }

  void reset() {
    _timer?.cancel();
    state = const QuizState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final quizStateProvider = StateNotifierProvider<QuizController, QuizState>(
  (ref) => QuizController(getIt()),
);

class MiniGameScreen extends ConsumerWidget {
  const MiniGameScreen({super.key});

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizStateProvider);

    return CupertinoPageScaffold(
      backgroundColor: _bgBottom,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.18,
            colors: [
              Color(0xFF282836),
              _bgTop,
              _bgMid,
              _bgBottom,
            ],
            stops: [0, 0.32, 0.68, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 126),
            children: [
              const JogjaPageHeader(title: 'Jogja Quiz', subtitle: 'Kuis budaya dan sejarah Jogja yang lebih seru.'),
              const SizedBox(height: 18),
              if (state.errorMessage != null) ...[
                _QuizErrorCard(message: state.errorMessage!),
                const SizedBox(height: 14),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: switch (state.phase) {
                  QuizPhase.lobby => _QuizLobbyView(
                      key: const ValueKey('lobby'),
                      onStart: () =>
                          ref.read(quizStateProvider.notifier).start(),
                    ),
                  QuizPhase.question => _QuizQuestionView(
                      key: ValueKey('question-${state.questionIndex}'),
                      state: state,
                      onAnswer: (index) =>
                          ref.read(quizStateProvider.notifier).answer(index),
                    ),
                  QuizPhase.result => _QuizResultView(
                      key: const ValueKey('result'),
                      score: state.score,
                      total: state.questions.length,
                      answered: state.answers.length,
                      correct: state.correctAnswers,
                      onReplay: () =>
                          ref.read(quizStateProvider.notifier).reset(),
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _QuizErrorCard extends StatelessWidget {
  const _QuizErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 28,
      opacity: 0.08,
      borderRadius: 22,
      borderColor: CupertinoColors.systemOrange.withOpacity(0.25),
      padding: const EdgeInsets.all(14),
      child: Text(
        message,
        style: AppTypography.textRegular13.copyWith(
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }
}

// ignore: unused_element
class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.phase,
    required this.score,
  });

  final QuizPhase phase;
  final int score;

  @override
  Widget build(BuildContext context) {
    final label = switch (phase) {
      QuizPhase.lobby => 'Ready',
      QuizPhase.question => 'Skor $score',
      QuizPhase.result => 'Finished',
    };

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentSecondary.withOpacity(0.14),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.10),
            ),
          ),
          child: const Icon(
            CupertinoIcons.gamecontroller_fill,
            size: 22,
            color: AppColors.accentSecondary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jogja Quiz',
                style: AppTypography.displayBold34.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  letterSpacing: -1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mini game budaya, wisata, dan hidden facts Jogja.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textRegular13.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GlassCard(
          blur: 24,
          opacity: 0.07,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.09),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Text(
            label,
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizLobbyView extends StatelessWidget {
  const _QuizLobbyView({
    required this.onStart,
    super.key,
  });

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.078,
      borderRadius: 30,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.15,
            colors: [
              AppColors.accentSecondary.withOpacity(0.14),
              CupertinoColors.white.withOpacity(0.038),
              CupertinoColors.black.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSecondary.withOpacity(0.14),
                border: Border.all(
                  color: CupertinoColors.white.withOpacity(0.10),
                ),
              ),
              child: const Icon(
                CupertinoIcons.sparkles,
                size: 30,
                color: AppColors.accentSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Tes pengetahuan Jogjamu',
              textAlign: TextAlign.center,
              style: AppTypography.displaySemi22.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: -0.55,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jawab 5 pertanyaan acak. Skor dihitung dari ketepatan dan kecepatanmu menjawab.',
              textAlign: TextAlign.center,
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            _PrimaryGameButton(
              label: 'Mulai Kuis',
              onTap: onStart,
            ),
            const SizedBox(height: 18),
            const _QuizHistoryPreview(),
          ],
        ),
      ),
    );
  }
}


class _QuizHistoryPreview extends StatelessWidget {
  const _QuizHistoryPreview();

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<QuizScoreModel>(AppConstants.quizScoresBox);

    return ValueListenableBuilder<Box<QuizScoreModel>>(
      valueListenable: box.listenable(),
      builder: (context, value, _) {
        final scores = value.values.toList()
          ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
        final latest = scores.take(5).toList();
        final bestScore = scores.fold<int>(0, (best, item) => item.score > best ? item.score : best);

        return GlassCard(
          blur: 24,
          opacity: 0.055,
          borderRadius: 24,
          borderColor: CupertinoColors.white.withOpacity(0.09),
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentTertiary.withOpacity(0.13),
                    ),
                    child: const Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      size: 17,
                      color: AppColors.accentTertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Skor',
                          style: AppTypography.textMedium15.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scores.isEmpty
                              ? 'Belum ada skor. Mainkan kuis pertama, monggo.'
                              : 'Skor terbaik $bestScore poin dari ${scores.length} percobaan.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.captionSmall11.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (latest.isNotEmpty) ...[
                const SizedBox(height: 13),
                ...List.generate(latest.length, (index) {
                  final item = latest[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == latest.length - 1 ? 0 : 9),
                    child: _QuizHistoryRow(score: item),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _QuizHistoryRow extends StatelessWidget {
  const _QuizHistoryRow({required this.score});

  final QuizScoreModel score;

  String _dateLabel(DateTime value) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day $month $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = score.total == 0 ? 0 : ((score.correct / score.total) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: CupertinoColors.white.withOpacity(0.035),
        border: Border.all(color: CupertinoColors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateLabel(score.playedAt),
                  style: AppTypography.captionSmall11.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${score.correct}/${score.total} benar • Akurasi $accuracy%',
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${score.score}',
            style: AppTypography.displaySemi22.copyWith(
              color: AppColors.accentSecondary,
              letterSpacing: -0.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizQuestionView extends StatelessWidget {
  const _QuizQuestionView({
    required this.state,
    required this.onAnswer,
    super.key,
  });

  final QuizState state;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final number = state.questionIndex + 1;
    final total = state.questions.length;

    return Column(
      children: [
        GlassCard(
          blur: 34,
          opacity: 0.078,
          borderRadius: 30,
          borderColor: CupertinoColors.white.withOpacity(0.12),
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.15,
                colors: [
                  AppColors.accentTertiary.withOpacity(0.13),
                  CupertinoColors.white.withOpacity(0.038),
                  CupertinoColors.black.withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    QuizTimerArc(progress: state.timeLeft / 15),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question $number of $total',
                            style: AppTypography.captionSmall11.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.isSubmitting
                                ? 'Submitting...'
                                : '${state.timeLeft}s left',
                            style: AppTypography.displaySemi22.copyWith(
                              color: AppColors.textPrimary,
                              letterSpacing: -0.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ScorePill(score: state.score),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  question.question,
                  textAlign: TextAlign.left,
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.18,
                    letterSpacing: -0.55,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(
          question.options.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AnswerOption(
              index: index,
              text: question.options[index].text,
              enabled: !state.isSubmitting,
              onTap: () => onAnswer(index),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.score,
    required this.total,
    required this.answered,
    required this.correct,
    required this.onReplay,
    super.key,
  });

  final int score;
  final int total;
  final int answered;
  final int correct;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.078,
      borderRadius: 30,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.15,
            colors: [
              AppColors.accentTertiary.withOpacity(0.14),
              CupertinoColors.white.withOpacity(0.038),
              CupertinoColors.black.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              '$score',
              style: AppTypography.displayBold34.copyWith(
                color: AppColors.textPrimary,
                fontSize: 64,
                letterSpacing: -2.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Skor Akhir',
              style: AppTypography.displaySemi22.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: -0.55,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$correct dari $total jawaban benar. $answered pertanyaan dijawab, mantap!.',
              textAlign: TextAlign.center,
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            _PrimaryGameButton(
              label: 'Main Lagi',
              onTap: onReplay,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerOption extends StatefulWidget {
  const _AnswerOption({
    required this.index,
    required this.text,
    required this.onTap,
    this.enabled = true,
  });

  final int index;
  final String text;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<_AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<_AnswerOption> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + widget.index);

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
      onTapCancel: widget.enabled ? () => _setPressed(false) : null,
      onTapUp: widget.enabled
          ? (_) {
              _setPressed(false);
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.65,
          child: GlassCard(
            blur: 28,
            opacity: 0.070,
            borderRadius: 24,
            borderColor: CupertinoColors.white.withOpacity(0.10),
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentSecondary.withOpacity(0.14),
                  ),
                  child: Text(
                    letter,
                    style: AppTypography.textMedium15.copyWith(
                      color: AppColors.accentSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.text,
                    style: AppTypography.textRegular13.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 24,
      opacity: 0.07,
      borderRadius: 999,
      borderColor: CupertinoColors.white.withOpacity(0.09),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      child: Text(
        '$score pts',
        style: AppTypography.captionSmall11.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _PrimaryGameButton extends StatefulWidget {
  const _PrimaryGameButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimaryGameButton> createState() => _PrimaryGameButtonState();
}

class _PrimaryGameButtonState extends State<_PrimaryGameButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentPrimary.withOpacity(0.95),
                AppColors.accentPrimary.withOpacity(0.72),
              ],
            ),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.18),
              width: 0.8,
            ),
          ),
          child: Text(
            widget.label,
            style: AppTypography.textMedium15.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}
