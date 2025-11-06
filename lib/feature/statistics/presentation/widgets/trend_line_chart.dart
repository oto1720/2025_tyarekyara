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

    // Prefer fixed 0..8 ticks (8,6,4,2,0). If data exceeds 8, expand the range.
    final chartMax = maxY > 8.0 ? (maxY + 2.0) : 8.0;

    final lineColor = const Color(0xFF6366F1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SizedBox(
              // Increase height to make the chart closer to square
              height: 220,
              // Limit width so the chart doesn't stretch too wide on large screens
              width: 320,
              child: LineChart(
              LineChartData(
                // Change tooltip text color to white and use the line color as
                // tooltip background so the white text is readable.
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                // Draw vertical grid only at integer x (week) positions.
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: const Color(0xFFEBEEF2),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
                getDrawingVerticalLine: (value) {
                  // Only draw at integer positions (week markers). For intermediate
                  // positions, return a transparent line so nothing is drawn.
                  if (value % 1 != 0) {
                    return const FlLine(color: Colors.transparent, strokeWidth: 0);
                  }
                  return FlLine(
                    color: const Color(0xFFEBEEF2),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    // Use 4 intervals so ticks become chartMax/4 apart. For chartMax==8 -> interval=2
                    interval: chartMax / 4,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      // When chartMax is 8 we expect ticks 0,2,4,6,8 — show integers only
                      if (chartMax == 8.0) {
                        if (value % 2 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= pts.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          '${idx + 1}週目',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    interval: 1,
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: lineColor,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 5,
                      color: lineColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),

                  belowBarData: BarAreaData(show: false),
                ),
              ],
              minY: 0,
              maxY: chartMax,
            ),
          ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend centered like the design
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: lineColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '投稿数',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
