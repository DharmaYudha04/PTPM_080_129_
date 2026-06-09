import 'package:flutter/cupertino.dart';

import '../../data/quiz_remote_datasource.dart';
import '../../../../shared/widgets/glass_card.dart';

class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    required this.question,
    required this.onAnswer,
    super.key,
  });

  final QuizQuestion question;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.question),
          const SizedBox(height: 16),
          ...List.generate(
            question.options.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CupertinoButton.filled(
                onPressed: () => onAnswer(index),
                child: Text(question.options[index].text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
