import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_statistics.dart';
import '../models/diversity_score.dart';
import '../models/stance_distribution.dart';
import '../models/participation_trend.dart';

/// Simple local repository storing JSON-serialized statistics in SharedPreferences.
class LocalStatisticsRepository {
  LocalStatisticsRepository();

  static String _userKey(String userId) => 'statistics:user:$userId';
  static String _diversityKey(String userId) => 'statistics:diversity:$userId';
  static String _stanceKey(String userId) => 'statistics:stance:$userId';
  static String _trendKey(String userId) => 'statistics:trend:$userId';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<UserStatistics?> fetchUserStatistics(String userId) async {
    final p = await _prefs;
    final s = p.getString(_userKey(userId));
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return UserStatistics.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserStatistics(UserStatistics stats) async {
    final p = await _prefs;
    await p.setString(_userKey(stats.userId), jsonEncode(stats.toJson()));
  }

  Future<DiversityScore?> fetchDiversityScore(String userId) async {
    final p = await _prefs;
    final s = p.getString(_diversityKey(userId));
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return DiversityScore.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDiversityScore(DiversityScore score) async {
    final p = await _prefs;
    await p.setString(_diversityKey(score.userId), jsonEncode(score.toJson()));
  }

  Future<StanceDistribution?> fetchStanceDistribution(String userId) async {
    final p = await _prefs;
    final s = p.getString(_stanceKey(userId));
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return StanceDistribution.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveStanceDistribution(StanceDistribution stance) async {
    final p = await _prefs;
    await p.setString(_stanceKey(stance.userId), jsonEncode(stance.toJson()));
  }

  Future<ParticipationTrend?> fetchParticipationTrend(String userId, {required int year, required int month}) async {
    final p = await _prefs;
    final s = p.getString(_trendKey(userId));
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return ParticipationTrend.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveParticipationTrend(ParticipationTrend trend) async {
    final p = await _prefs;
    await p.setString(_trendKey(trend.userId), jsonEncode(trend.toJson()));
  }

  /// Save all pieces together atomically (best-effort)
  Future<void> saveAll({
    required UserStatistics userStatistics,
    required DiversityScore diversityScore,
    required StanceDistribution stanceDistribution,
    required ParticipationTrend participationTrend,
  }) async {
    await saveUserStatistics(userStatistics);
    await saveDiversityScore(diversityScore);
    await saveStanceDistribution(stanceDistribution);
    await saveParticipationTrend(participationTrend);
  }
}
