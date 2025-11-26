import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'あなたの思考プロフィール',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '多様な視点に触れることで、思考の幅が広がります',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ParticipationStatsCardImpl(
                  title: '連続日数',
                  value: userStatistics != null
                      ? '${userStatistics!.consecutiveDays}日'
                      : '--',
                  accentColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ParticipationStatsCardImpl(
                  title: '総投稿数',
                  value: userStatistics != null
                      ? '${userStatistics!.totalOpinions}件'
                      : '--',
                  accentColor: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
