import '../models/badge.dart';
import '../models/earned_badge.dart';

abstract class BadgeRepository {
  Future<List<Badge>> fetchCatalog();
  Future<List<Badge>> fetchEarnedBadges(String userId);
  Future<void> saveEarnedBadge(String userId, EarnedBadge earnedBadge);
}
