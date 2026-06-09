import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/metric_card.dart';

class QuickGuideRow extends StatelessWidget {
  const QuickGuideRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.sparkles,
                label: 'Kanca',
                value: 'Jogja',
                color: AppColors.accentPrimary,
                onTap: () => context.go(RouteNames.guide),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.gamecontroller_fill,
                label: 'Kuis',
                value: 'Budaya',
                color: AppColors.accentTertiary,
                onTap: () => context.push(RouteNames.game),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.money_dollar_circle,
                label: 'Konversi',
                value: 'Kurs',
                color: AppColors.accentPrimary,
                onTap: () => context.push('${RouteNames.converter}?tab=currency'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: CupertinoIcons.time,
                label: 'Konversi',
                value: 'Waktu',
                color: AppColors.accentTertiary,
                onTap: () => context.push('${RouteNames.converter}?tab=time'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
