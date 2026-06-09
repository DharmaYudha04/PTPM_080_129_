import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/glass_card.dart';

class QuizResultCard extends StatelessWidget {
  const QuizResultCard({
    required this.score,
    required this.onReplay,
    super.key,
  });

  final int score;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text('Skor kamu: $score'),
          const SizedBox(height: 12),
          CupertinoButton.filled(
            onPressed: onReplay,
            child: const Text('Main lagi'),
          ),
        ],
      ),
    );
  }
}
