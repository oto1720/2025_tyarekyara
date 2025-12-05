import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/badge_definition.dart';
import '../../providers/statistics_provider.dart';

class BadgeListScreen extends ConsumerWidget {
  const BadgeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsNotifierProvider);
    final earnedBadgeIds = state.earnedBadges.map((b) => b.id).toSet();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'バッジ一覧',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 獲得済みバッジ数
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    '${earnedBadgeIds.length} / ${BadgeDefinitions.all.length}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '獲得済みバッジ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // バッジ一覧
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BadgeDefinitions.all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final badgeDef = BadgeDefinitions.all[index];
                final isEarned = earnedBadgeIds.contains(badgeDef.id);

                return _BadgeCard(
                  badge: badgeDef,
                  isEarned: isEarned,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeDefinition badge;
  final bool isEarned;

  const _BadgeCard({
    required this.badge,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isEarned ? 1.0 : 0.3;
    final backgroundColor = isEarned
        ? badge.color.withValues(alpha: 0.1)
        : AppColors.textTertiary.withValues(alpha: 0.05);
    final borderColor = isEarned
        ? badge.color.withValues(alpha: 0.3)
        : AppColors.textTertiary.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // アイコン
          Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEarned
                    ? badge.color.withValues(alpha: 0.2)
                    : AppColors.textTertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 28,
                color: isEarned ? badge.color : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // バッジ名
          Opacity(
            opacity: opacity,
            child: Text(
              badge.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isEarned ? AppColors.textPrimary : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),

          // 説明
          Opacity(
            opacity: opacity,
            child: Text(
              badge.description,
              style: TextStyle(
                fontSize: 10,
                color: isEarned ? AppColors.textSecondary : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 獲得済みマーク
          if (isEarned) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badge.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '獲得済み',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
