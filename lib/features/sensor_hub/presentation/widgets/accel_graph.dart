import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

class AccelGraph extends StatelessWidget {
  const AccelGraph({required this.values, super.key});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final spots = values
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
