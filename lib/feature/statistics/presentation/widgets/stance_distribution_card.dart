import 'package:flutter/material.dart';
import '../../models/stance_distribution.dart';
import 'stance_pie_chart.dart';

class StanceDistributionCardImpl extends StatelessWidget {
  const StanceDistributionCardImpl({super.key, this.stance});

  final StanceDistribution? stance;

  @override
  Widget build(BuildContext context) {
    final counts = stance?.counts ?? {'賛成': 45, '反対': 55};
    final total = stance?.total ?? counts.values.fold<int>(0, (a, b) => a + b);
    final max = counts.values.isEmpty
        ? 0
        : counts.values.reduce((a, b) => a > b ? a : b);
    final min = counts.values.isEmpty
        ? 0
        : counts.values.reduce((a, b) => a < b ? a : b);
    final majorityPct = total > 0 ? ((max / total) * 100).round() : 0;
    final minorityPct = total > 0 ? ((min / total) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'あなたの立場分布',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'どの立場で意見を述べることが多いですか？',
            style: TextStyle(color: Color(0xFF717182)),
          ),
          const SizedBox(height: 12),
          StancePieChartImpl(stance: stance),
          const SizedBox(height: 12),
          // majority/minority rows
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _StatRow(label: '多数派の意見', percent: '$majorityPct%'),
                const SizedBox(height: 8),
                _StatRow(label: '少数派の意見', percent: '$minorityPct%'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'あなたは少数派の意見を積極的に表明しています',
            style: TextStyle(color: Color(0xFF717182)),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.percent});
  final String label;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(percent, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
