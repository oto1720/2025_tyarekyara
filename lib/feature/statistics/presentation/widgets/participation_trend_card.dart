import 'package:flutter/material.dart';
import '../../models/participation_trend.dart';
import 'trend_line_chart.dart';

class ParticipationTrendCardImpl extends StatelessWidget {
  const ParticipationTrendCardImpl({super.key, this.trend});

  final ParticipationTrend? trend;

  @override
  Widget build(BuildContext context) {
    final pts = trend?.points.map((p) => p.count).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '参加の推移',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TrendLineChartImpl(points: pts),
          const SizedBox(height: 8),
          const Center(
            child: Text('投稿数', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }
}
