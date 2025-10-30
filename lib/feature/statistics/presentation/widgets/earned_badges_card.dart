import 'package:flutter/material.dart';
import '../../models/badge.dart' as stats_model;
import 'badge_grid_item.dart';

class EarnedBadgesCardImpl extends StatelessWidget {
  const EarnedBadgesCardImpl({super.key, this.earnedBadges});

  final List<stats_model.Badge>? earnedBadges;

  @override
  Widget build(BuildContext context) {
    final badges = earnedBadges != null && earnedBadges!.isNotEmpty
        ? earnedBadges!
        : [
            stats_model.Badge(
              id: 'sample1',
              name: '初投稿',
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
            stats_model.Badge(
              id: 'sample2',
              name: '7日連続参加',
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
            stats_model.Badge(
              id: 'sample3',
              name: '多様な思考者',
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
          ];

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
            '獲得バッジ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final b = badges[index];
              return BadgeGridItemImpl(
                name: b.name,
                earned: b.earnedAt != null,
              );
            },
          ),
        ],
      ),
    );
  }
}
