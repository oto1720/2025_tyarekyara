import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendLineChartImpl extends StatelessWidget {
  const TrendLineChartImpl({super.key, this.points});

  final List<int>? points;

  @override
  Widget build(BuildContext context) {
    final pts = points ?? [5, 6, 8, 6, 7, 8];
    final spots = <FlSpot>[];
    for (var i = 0; i < pts.length; i++) {
      spots.add(FlSpot(i.toDouble(), pts[i].toDouble()));
    }

    final maxY = pts.isNotEmpty
        ? pts.reduce((a, b) => a > b ? a : b).toDouble()
        : 10.0;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: const Color(0xFFEBEEF2), strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF6366F1),
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF6366F1).withOpacity(0.12),
              ),
            ),
          ],
          minY: 0,
          maxY: maxY + 2,
        ),
      ),
    );
  }
}
