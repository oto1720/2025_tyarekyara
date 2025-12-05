import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debate_match.dart';
import 'package:flutter/foundation.dart';
/// ディベートマッチリポジトリ
class DebateMatchRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'debate_matches';
  static const String _entriesCollectionName = 'debate_entries';

  DebateMatchRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// エントリーを作成
  Future<void> createEntry(DebateEntry entry) async {
    try {
      final docId = '${entry.eventId}_${entry.userId}';
      await _firestore
          .collection(_entriesCollectionName)
          .doc(docId)
          .set(DebateEntry.toFirestore(entry));
    } catch (e) {
      debugPrint('Error creating entry: $e');
      rethrow;
    }
  }

  /// イベントのエントリー数を取得
  Future<int> getEntryCount(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(_entriesCollectionName)
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: MatchStatus.waiting.name)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting entry count: $e');
      return 0;
    }
  }

  /// ユーザーのエントリーを取得
  Future<DebateEntry?> getUserEntry(String eventId, String userId) async {
    try {
      final docId = '${eventId}_$userId';
      final doc = await _firestore
          .collection(_entriesCollectionName)
          .doc(docId)
          .get();

      if (!doc.exists) return null;
      return DebateEntry.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting user entry: $e');
      return null;
    }
  }

  /// ユーザーのエントリーをリアルタイム監視
  Stream<DebateEntry?> watchUserEntry(String eventId, String userId) {
    final docId = '${eventId}_$userId';
    return _firestore
        .collection(_entriesCollectionName)
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return DebateEntry.fromJson(doc.data()!);
    });
  }

  /// エントリーをキャンセル
  Future<void> cancelEntry(String eventId, String userId) async {
    try {
      final docId = '${eventId}_$userId';
      await _firestore
          .collection(_entriesCollectionName)
          .doc(docId)
          .update({
        'status': MatchStatus.cancelled.name,
      });
    } catch (e) {
      debugPrint('Error cancelling entry: $e');
      rethrow;
    }
  }

  /// ユーザーの現在のマッチを取得
  Future<DebateMatch?> getCurrentMatch(String userId) async {
    try {
      // proTeamにいる場合を検索
      var snapshot = await _firestore
          .collection(_collectionName)
          .where('proTeam.memberIds', arrayContains: userId)
          .where('status', whereIn: [
            MatchStatus.matched.name,
            MatchStatus.inProgress.name,
          ])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return DebateMatch.fromJson(snapshot.docs.first.data());
      }

      // conTeamにいる場合を検索
      snapshot = await _firestore
          .collection(_collectionName)
          .where('conTeam.memberIds', arrayContains: userId)
          .where('status', whereIn: [
            MatchStatus.matched.name,
            MatchStatus.inProgress.name,
          ])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return DebateMatch.fromJson(snapshot.docs.first.data());
      }

      return null;
    } catch (e) {
      debugPrint('Error getting current match: $e');
      return null;
    }
  }

  /// マッチをリアルタイム監視
  Stream<DebateMatch?> watchMatch(String matchId) {
    return _firestore
        .collection(_collectionName)
        .doc(matchId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return DebateMatch.fromJson(doc.data()!);
    });
  }

  /// ユーザーのマッチ履歴を取得
  Future<List<DebateMatch>> getUserMatchHistory(
    String userId, {
    int limit = 20,
  }) async {
    try {
      // proTeamとconTeamの両方を検索して統合する必要がある
      // Firestoreの制限により、2回クエリを実行
      // 注意: orderByは複合インデックスが必要なため、メモリ内でソートする
      final proMatches = await _firestore
          .collection(_collectionName)
          .where('proTeam.memberIds', arrayContains: userId)
          .get();

      debugPrint('Pro matches found: ${proMatches.docs.length}');

      final conMatches = await _firestore
          .collection(_collectionName)
          .where('conTeam.memberIds', arrayContains: userId)
          .get();

      debugPrint('Con matches found: ${conMatches.docs.length}');

      final allMatches = <DebateMatch>[];

      for (final doc in proMatches.docs) {
        try {
          allMatches.add(DebateMatch.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing pro match ${doc.id}: $e');
        }
      }

      for (final doc in conMatches.docs) {
        try {
          allMatches.add(DebateMatch.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing con match ${doc.id}: $e');
        }
      }

      // 重複を除去してソート
      final uniqueMatches = <String, DebateMatch>{};
      for (final match in allMatches) {
        uniqueMatches[match.id] = match;
      }

      final result = uniqueMatches.values.toList()
        ..sort((a, b) => b.matchedAt.compareTo(a.matchedAt));

      debugPrint('Total unique matches: ${result.length}');

      return result.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting user match history: $e');
      return [];
    }
  }

  /// マッチを更新
  Future<void> updateMatch(DebateMatch match) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(match.id)
          .update(DebateMatch.toFirestore(match));
    } catch (e) {
      debugPrint('Error updating match: $e');
      rethrow;
    }
  }

  /// ユーザーを準備完了としてマーク
  Future<void> markUserAsReady(String matchId, String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(matchId).update({
        'readyUsers': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Error marking user as ready: $e');
      rethrow;
    }
  }

  /// 特定イベントのユーザーマッチを取得
  Future<DebateMatch?> getUserMatchByEvent(String eventId, String userId) async {
    try {
      // proTeamにいる場合を検索
      var snapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('proTeam.memberIds', arrayContains: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return DebateMatch.fromJson(snapshot.docs.first.data());
      }

      // conTeamにいる場合を検索
      snapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .where('conTeam.memberIds', arrayContains: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return DebateMatch.fromJson(snapshot.docs.first.data());
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user match by event: $e');
      return null;
    }
  }
}
