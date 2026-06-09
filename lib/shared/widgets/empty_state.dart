import 'package:flutter/cupertino.dart';

import '../../core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.message, super.key});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.sparkles, size: 40),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.displaySemi20),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.textRegular13,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
