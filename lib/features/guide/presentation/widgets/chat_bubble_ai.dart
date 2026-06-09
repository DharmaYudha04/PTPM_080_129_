import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/glass_card.dart';

class ChatBubbleAi extends StatelessWidget {
  const ChatBubbleAi({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassCard(child: Text(message)),
    );
  }
}
