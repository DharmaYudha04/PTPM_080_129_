import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/bottom_sheet_wrapper.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({required this.onSelected, super.key});

  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = ['Budaya', 'Sejarah', 'Alam', 'Kuliner', 'Belanja', 'Seni', 'Aktivitas', 'Foto', 'Keluarga'];
    return BottomSheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter destinasi', style: AppTypography.displaySemi20),
          const SizedBox(height: 6),
          Text(
            'Pilih suasana jalan-jalan yang kamu mau. Filter ini cocok dengan kategori, tipe, dan tag destinasi di database.',
            style: AppTypography.textRegular13.copyWith(color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 16),
          ...categories.map(
            (category) => CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              onPressed: () {
                onSelected(category);
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  const Icon(CupertinoIcons.tag_fill, size: 18, color: AppColors.accentPrimary),
                  const SizedBox(width: 10),
                  Text(category, style: AppTypography.textMedium15),
                ],
              ),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 8),
            onPressed: () {
              onSelected(null);
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                const Icon(CupertinoIcons.clear_circled_solid, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text('Tampilkan semua', style: AppTypography.textMedium15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
