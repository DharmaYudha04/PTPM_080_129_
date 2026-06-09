import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/glass_card.dart';

class AICardResponse extends StatelessWidget {
  const AICardResponse({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title), const SizedBox(height: 6), Text(subtitle)],
      ),
    );
  }
}
