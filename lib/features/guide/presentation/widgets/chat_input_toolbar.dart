import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/glass_card.dart';

class ChatInputToolbar extends StatelessWidget {
  const ChatInputToolbar({
    required this.controller,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 999,
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField.borderless(
              controller: controller,
              placeholder: 'Tulis pertanyaanmu di sini, monggo...',
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onSend,
            child: const Icon(CupertinoIcons.arrow_up_circle_fill),
          ),
        ],
      ),
    );
  }
}
