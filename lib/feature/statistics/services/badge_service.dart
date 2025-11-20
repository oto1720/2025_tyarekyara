import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge.dart';
import '../models/earned_badge.dart';
import '../repositories/badge_repository.dart';
import '../repositories/badge_repository_impl.dart';

final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService(ref.watch(badgeRepositoryProvider));
});

class BadgeService {
  final BadgeRepository _repository;
  List<Badge> _catalogCache = [];
  bool _isCatalogLoaded = false;

  BadgeService(this._repository);

  Future<void> initialize() async {
    if (_isCatalogLoaded) return;
    _catalogCache = await _repository.fetchCatalog();
    _isCatalogLoaded = true;
  }

  Future<List<Badge>> fetchEarnedBadges(String userId) async {
    return _repository.fetchEarnedBadges(userId);
  }

  Future<void> checkCondition(
    String userId,
    String field,
    dynamic value,
  ) async {
    if (!_isCatalogLoaded) {
      await initialize();
    }

    // Fetch currently earned badges to avoid duplicates
    // Optimization: We could cache earned badges too, but for now let's fetch.
    // Or we can rely on the repository to handle duplicates or just check here.
    final earnedBadges = await _repository.fetchEarnedBadges(userId);
    final earnedBadgeIds = earnedBadges.map((b) => b.id).toSet();

    for (final badge in _catalogCache) {
      if (earnedBadgeIds.contains(badge.id)) continue;

      final criteria = badge.criteria;
      if (criteria == null) continue;

      // Check if criteria matches
      if (criteria['field'] == field) {
        // Simple equality check for now, can be extended for 'type', 'threshold', etc.
        // The user example: {days:"3", field:"login", type:"streak"}
        // If field matches, we need to check the logic based on 'type'.

        bool isMet = false;

        // Example logic based on user request
        if (criteria['type'] == 'streak') {
          // Assuming 'value' passed to checkCondition is the current streak count
          final requiredDays =
              int.tryParse(criteria['days']?.toString() ?? '0') ?? 0;
          final currentDays = int.tryParse(value?.toString() ?? '0') ?? 0;
          if (currentDays >= requiredDays) {
            isMet = true;
          }
        } else if (criteria['type'] == 'count') {
          // Generic count check
          final requiredCount =
              int.tryParse(criteria['count']?.toString() ?? '0') ?? 0;
          final currentCount = int.tryParse(value?.toString() ?? '0') ?? 0;
          if (currentCount >= requiredCount) {
            isMet = true;
          }
        } else {
          // Default equality check if no specific type logic
          if (criteria['value'] == value) {
            isMet = true;
          }
        }

        if (isMet) {
          final newEarnedBadge = EarnedBadge(
            badgeId: badge.id,
            earnedAt: DateTime.now(),
            awardedBy: 'system',
          );
          await _repository.saveEarnedBadge(userId, newEarnedBadge);
        }
      }
    }
  }
}
