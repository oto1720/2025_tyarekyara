import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/participation_trend.dart';
import '../../providers/statistics_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import 'trend_line_chart.dart';

class ParticipationTrendCardImpl extends ConsumerWidget {
  const ParticipationTrendCardImpl({super.key, this.trend});

  final ParticipationTrend? trend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pts = trend?.points.map((p) => p.count).toList();
    final state = ref.watch(statisticsNotifierProvider);
    final notifier = ref.read(statisticsNotifierProvider.notifier);

    final year = state.selectedYear ?? DateTime.now().year;
    final month = state.selectedMonth ?? DateTime.now().month;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '参加の推移',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () async {
                      notifier.goToPreviousMonth();
                      // データを再取得
                      final currentUser = await ref.read(currentUserProvider.future);
                      if (currentUser != null) {
                        notifier.loadUserStatistics(currentUser.id);
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$year年$month月',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () async {
                      notifier.goToNextMonth();
                      // データを再取得
                      final currentUser = await ref.read(currentUserProvider.future);
                      if (currentUser != null) {
                        notifier.loadUserStatistics(currentUser.id);
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          // Increase spacing between title and chart for better separation
          const SizedBox(height: 32),
          TrendLineChartImpl(points: pts),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
