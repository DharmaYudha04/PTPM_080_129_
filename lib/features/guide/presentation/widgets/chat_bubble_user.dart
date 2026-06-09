import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

class ChatBubbleUser extends StatelessWidget {
  const ChatBubbleUser({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accentPrimary.withOpacity(0.28),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(message),
      ),
    );
  }
}
