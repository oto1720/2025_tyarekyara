import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/stance_distribution.dart';

class StancePieChartImpl extends StatelessWidget {
  const StancePieChartImpl({super.key, this.stance});

  final StanceDistribution? stance;

  @override
  Widget build(BuildContext context) {
    final items = stance?.counts.map((k, v) => MapEntry(k, v.toDouble())) ??
        {'賛成': 16, '中立': 8, '反対': 12};
    final total = items.values.fold<double>(0, (a, b) => a + b);
    final colors = [
      const Color(0xFF10B981),
      const Color(0xFF60A5FA),
      const Color(0xFFFB7185),
    ];

    final sections = <PieChartSectionData>[];
    var i = 0;
    for (final e in items.entries) {
      final value = e.value;
      final pct = total > 0 ? value / total : 0.0;
      sections.add(PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '${(pct * 100).round()}%',
        radius: 48,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      i++;
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 28,
              sectionsSpace: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // legend
        Column(
          children: items.entries.map((e) {
            final idx = items.keys.toList().indexOf(e.key) % colors.length;
            final pct = total > 0 ? (e.value / total * 100).round() : 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(width: 12, height: 12, color: colors[idx]),
                  const SizedBox(width: 8),
                  Text(e.key, style: const TextStyle(fontSize: 14)),
                  const Spacer(),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0F172B),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
