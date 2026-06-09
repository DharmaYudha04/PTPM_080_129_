import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/category_pill.dart';

class SuggestionChipsRow extends StatelessWidget {
  const SuggestionChipsRow({required this.onSelected, super.key});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'Rekomendasi hari ini',
      'Budaya dekat saya',
      'Hidden gems kuliner',
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => onSelected(suggestions[index]),
          child: CategoryPill(suggestions[index]),
        ),
      ),
    );
  }
}
