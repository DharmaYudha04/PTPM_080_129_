import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/glass_button.dart';

class QuizLobby extends StatelessWidget {
  const QuizLobby({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Quiz Jogja'),
        const SizedBox(height: 12),
        GlassButton(label: 'Mulai', filled: true, onPressed: onStart),
      ],
    );
  }
}
