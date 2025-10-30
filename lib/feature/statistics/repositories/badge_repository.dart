import '../models/badge.dart';

abstract class BadgeRepository {
  Future<List<Badge>> fetchEarnedBadges(String userId);
}
