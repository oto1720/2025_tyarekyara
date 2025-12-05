import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_debate_stats.dart';
import 'package:flutter/foundation.dart';
/// ユーザーディベート統計リポジトリ
class UserDebateStatsRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'user_debate_stats';
  static const String _rankingsCollectionName = 'debate_rankings';

  UserDebateStatsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ユーザー統計を取得
  Future<UserDebateStats?> getUserStats(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (!doc.exists) {
        // 統計が存在しない場合は初期化
        return _createInitialStats(userId);
      }
      return UserDebateStats.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return null;
    }
  }

  /// ユーザー統計をリアルタイム監視
  Stream<UserDebateStats?> watchUserStats(String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserDebateStats.fromJson(doc.data()!);
    });
  }

  /// 初期統計を作成
  UserDebateStats _createInitialStats(String userId) {
    return UserDebateStats(
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      badges: [DebateBadge.rookie],
    );
  }

  /// 統計を保存
  Future<void> saveStats(UserDebateStats stats) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(stats.userId)
          .set(UserDebateStats.toFirestore(stats));
    } catch (e) {
      debugPrint('Error saving stats: $e');
      rethrow;
    }
  }

  /// 統計を更新
  Future<void> updateStats(UserDebateStats stats) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(stats.userId)
          .update(UserDebateStats.toFirestore(stats));
    } catch (e) {
      debugPrint('Error updating stats: $e');
      rethrow;
    }
  }

  /// ランキングを取得
  Future<List<RankingEntry>> getRanking(
    String rankingType, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_rankingsCollectionName)
          .doc(rankingType)
          .collection('users')
          .orderBy('value', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => RankingEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting ranking: $e');
      return [];
    }
  }

  /// 月間ポイントランキングを取得
  Future<List<RankingEntry>> getMonthlyPointsRanking({int limit = 100}) async {
    return getRanking('monthly_points', limit: limit);
  }

  /// 通算勝利数ランキングを取得
  Future<List<RankingEntry>> getTotalWinsRanking({int limit = 100}) async {
    return getRanking('total_wins', limit: limit);
  }

  /// MVP獲得数ランキングを取得
  Future<List<RankingEntry>> getMvpCountRanking({int limit = 100}) async {
    return getRanking('mvp_count', limit: limit);
  }

  /// 総ポイントランキングを取得
  Future<List<RankingEntry>> getTotalPointsRanking({int limit = 100}) async {
    return getRanking('total_points', limit: limit);
  }

  /// 勝率ランキングを取得
  Future<List<RankingEntry>> getWinRateRanking({int limit = 100}) async {
    return getRanking('win_rate', limit: limit);
  }

  /// 参加数ランキングを取得
  Future<List<RankingEntry>> getParticipationRanking({int limit = 100}) async {
    return getRanking('participation', limit: limit);
  }

  /// ユーザーのランク位置を取得
  Future<int?> getUserRank(String rankingType, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_rankingsCollectionName)
          .doc(rankingType)
          .collection('users')
          .doc(userId)
          .get();

      if (!snapshot.exists) return null;
      final data = RankingEntry.fromJson(snapshot.data()!);
      return data.rank;
    } catch (e) {
      debugPrint('Error getting user rank: $e');
      return null;
    }
  }

  /// バッジを追加
  Future<void> addBadge(String userId, DebateBadge badge) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .update({
        'badges': FieldValue.arrayUnion([badge.name]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error adding badge: $e');
      rethrow;
    }
  }

  /// 月次リセット
  Future<void> resetMonthlyPoints(String userId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .update({
        'currentMonthPoints': 0,
        'lastMonthlyReset': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error resetting monthly points: $e');
      rethrow;
    }
  }
}
