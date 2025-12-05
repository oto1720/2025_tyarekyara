import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/badge.dart' as stats_model;
import 'badge_grid_item.dart';

class EarnedBadgesCardImpl extends StatelessWidget {
  const EarnedBadgesCardImpl({super.key, this.earnedBadges});

  final List<stats_model.Badge>? earnedBadges;

  @override
  Widget build(BuildContext context) {
    final allBadges = earnedBadges ?? [];
    // 最大3つまで表示
    final displayBadges = allBadges.take(3).toList();
    final hasMore = allBadges.length > 3;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '獲得バッジ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.push('/statistics/badges');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text(
                      '詳細',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF6366F1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (displayBadges.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'まだバッジを獲得していません',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayBadges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                final b = displayBadges[index];
                return BadgeGridItemImpl(
                  name: b.name,
                  earned: true,
                );
              },
            ),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '他${allBadges.length - 3}個のバッジ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
