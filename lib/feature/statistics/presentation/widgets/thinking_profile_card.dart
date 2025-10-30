import 'package:flutter/material.dart';
import '../../models/user_statistics.dart';
import 'participation_stats_card.dart';

class ThinkingProfileCardImpl extends StatelessWidget {
  const ThinkingProfileCardImpl({super.key, this.userStatistics});

  final UserStatistics? userStatistics;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFFAF5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFC6D2FF), width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'あなたの思考プロフィール',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF0F172B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '多様な視点に触れることで、思考の幅が広がります',
            style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ParticipationStatsCardImpl(
                  title: '参加日数',
                  value: userStatistics != null
                      ? '${userStatistics!.participationDays}日'
                      : '--',
                  accentColor: const Color(0xFF4F39F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ParticipationStatsCardImpl(
                  title: '総投稿数',
                  value: userStatistics != null
                      ? '${userStatistics!.totalOpinions}件'
                      : '--',
                  accentColor: const Color(0xFF9810FA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
