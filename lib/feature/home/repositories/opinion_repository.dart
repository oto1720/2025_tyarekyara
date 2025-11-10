import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opinion.dart';

/// 意見をFirestoreで管理するリポジトリ
class OpinionRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'opinions';

  OpinionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 意見を投稿
  Future<void> postOpinion(Opinion opinion) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(opinion.id)
          .set(opinion.toJson());
    } catch (e) {
      print('Error posting opinion: $e');
      rethrow;
    }
  }

  /// 特定のトピックに対する意見一覧を取得
  Future<List<Opinion>> getOpinionsByTopic(String topicId) async {
    try {
      // orderByを削除してインデックス不要にする
      // ソートはアプリ側で行う
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('topicId', isEqualTo: topicId)
          .where('isDeleted', isEqualTo: false)
          .get();

      final opinions = snapshot.docs
          .map((doc) => Opinion.fromJson(doc.data()))
          .toList();

      // アプリ側で作成日時の降順にソート
      opinions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return opinions;
    } catch (e) {
      print('Error getting opinions by topic: $e');
      return [];
    }
  }

  /// 特定のトピックの立場別意見数を取得
  Future<Map<OpinionStance, int>> getOpinionCountsByStance(
      String topicId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('topicId', isEqualTo: topicId)
          .where('isDeleted', isEqualTo: false)
          .get();

      final counts = <OpinionStance, int>{
        OpinionStance.agree: 0,
        OpinionStance.disagree: 0,
        OpinionStance.neutral: 0,
      };

      for (final doc in snapshot.docs) {
        final opinion = Opinion.fromJson(doc.data());
        counts[opinion.stance] = (counts[opinion.stance] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting opinion counts: $e');
      return {
        OpinionStance.agree: 0,
        OpinionStance.disagree: 0,
        OpinionStance.neutral: 0,
      };
    }
  }

  /// 特定ユーザーの意見を取得
  Future<List<Opinion>> getOpinionsByUser(String userId) async {
    try {
      // orderByを削除してインデックス不要にする
      // ソートはアプリ側で行う
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .get();

      final opinions = snapshot.docs
          .map((doc) => Opinion.fromJson(doc.data()))
          .toList();

      // アプリ側で作成日時の降順にソート
      opinions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return opinions;
    } catch (e) {
      print('Error getting opinions by user: $e');
      return [];
    }
  }

  /// ユーザーが特定のトピックに既に投稿しているか確認
  Future<bool> hasUserPostedOpinion(String topicId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('topicId', isEqualTo: topicId)
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user opinion: $e');
      return false;
    }
  }

  /// ユーザーの特定トピックに対する意見を取得
  Future<Opinion?> getUserOpinion(String topicId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('topicId', isEqualTo: topicId)
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Opinion.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting user opinion: $e');
      return null;
    }
  }

  /// 意見を削除（論理削除）
  Future<void> deleteOpinion(String opinionId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(opinionId)
          .update({'isDeleted': true});
    } catch (e) {
      print('Error deleting opinion: $e');
      rethrow;
    }
  }

  /// 意見を更新（編集）
  Future<void> updateOpinion({
    required String opinionId,
    required OpinionStance stance,
    required String content,
  }) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(opinionId)
          .update({
        'stance': stance.name,
        'content': content,
      });
    } catch (e) {
      print('Error updating opinion: $e');
      rethrow;
    }
  }

  /// 意見にいいねを追加
  Future<void> likeOpinion(String opinionId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(opinionId)
          .update({'likeCount': FieldValue.increment(1)});
    } catch (e) {
      print('Error liking opinion: $e');
      rethrow;
    }
  }

  /// リアルタイムで意見を取得（Stream）
  Stream<List<Opinion>> watchOpinionsByTopic(String topicId) {
    return _firestore
        .collection(_collectionName)
        .where('topicId', isEqualTo: topicId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final opinions = snapshot.docs
              .map((doc) => Opinion.fromJson(doc.data()))
              .toList();
          // アプリ側で作成日時の降順にソート
          opinions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return opinions;
        });
  }

  /// リアクションを追加
  Future<void> addReaction({
    required String opinionId,
    required String userId,
    required ReactionType type,
  }) async {
    try {
      final key = type.key;

      await _firestore.collection(_collectionName).doc(opinionId).update({
        'reactionCounts.$key': FieldValue.increment(1),
        'reactedUsers.$key': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error adding reaction: $e');
      rethrow;
    }
  }

  /// リアクションを削除
  Future<void> removeReaction({
    required String opinionId,
    required String userId,
    required ReactionType type,
  }) async {
    try {
      final key = type.key;

      await _firestore.collection(_collectionName).doc(opinionId).update({
        'reactionCounts.$key': FieldValue.increment(-1),
        'reactedUsers.$key': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error removing reaction: $e');
      rethrow;
    }
  }

  /// リアクションをトグル（追加/削除を自動判定）
  Future<void> toggleReaction({
    required String opinionId,
    required String userId,
    required ReactionType type,
  }) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(opinionId).get();
      if (!doc.exists) {
        throw Exception('Opinion not found');
      }

      final opinion = Opinion.fromJson(doc.data()!);
      final key = type.key;
      final reactedUsersList = opinion.reactedUsers[key] ?? [];
      final hasReacted = reactedUsersList.contains(userId);

      if (hasReacted) {
        // 既にリアクション済みなら削除
        await removeReaction(opinionId: opinionId, userId: userId, type: type);
      } else {
        // まだリアクションしていないなら追加
        await addReaction(opinionId: opinionId, userId: userId, type: type);
      }
    } catch (e) {
      print('Error toggling reaction: $e');
      rethrow;
    }
  }
}
