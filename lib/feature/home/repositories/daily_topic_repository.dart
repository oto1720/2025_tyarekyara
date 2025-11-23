import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic.dart';

/// 日別トピックをFirestoreで管理するリポジトリ
class DailyTopicRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'daily_topics';

  /// FirestoreのTimestampをISO8601文字列に変換
  static String? _timestampToString(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is String) return value;
    return null;
  }

  /// Firestoreのデータを変換（Timestamp→String）
  static Map<String, dynamic> _convertFirestoreData(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);

    // createdAtを変換
    if (converted['createdAt'] != null) {
      converted['createdAt'] = _timestampToString(converted['createdAt']);
    }

    // relatedNews内のpublishedAtを変換
    if (converted['relatedNews'] != null && converted['relatedNews'] is List) {
      converted['relatedNews'] = (converted['relatedNews'] as List).map((news) {
        if (news is Map<String, dynamic>) {
          final newsMap = Map<String, dynamic>.from(news);
          if (newsMap['publishedAt'] != null) {
            newsMap['publishedAt'] = _timestampToString(newsMap['publishedAt']);
          }
          return newsMap;
        }
        return news;
      }).toList();
    }

    return converted;
  }

  DailyTopicRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 今日の日付を'YYYY-MM-DD'形式で取得
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 今日のトピックを取得
  Future<Topic?> getTodayTopic() async {
    try {
      final dateKey = _getTodayKey();

      final doc = await _firestore
          .collection(_collectionName)
          .doc(dateKey)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = _convertFirestoreData(doc.data()!);
        return Topic.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting today topic: $e');
      return null;
    }
  }

  /// 今日のトピックを保存
  Future<void> saveTodayTopic(Topic topic) async {
    final dateKey = _getTodayKey();

    // TopicをJSONに変換
    final jsonData = topic.toJson();

    // relatedNewsを手動でJSON配列に変換（Firestoreサポートのため）
    if (topic.relatedNews.isNotEmpty) {
      jsonData['relatedNews'] = topic.relatedNews
          .map((newsItem) => newsItem.toJson())
          .toList();
    }

    await _firestore
        .collection(_collectionName)
        .doc(dateKey)
        .set(jsonData);
  }

  /// 特定の日付のトピックを取得
  Future<Topic?> getTopicByDate(DateTime date) async {
    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final doc = await _firestore
          .collection(_collectionName)
          .doc(dateKey)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = _convertFirestoreData(doc.data()!);
        return Topic.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting topic by date: $e');
      return null;
    }
  }

  /// 過去のトピック一覧を取得（最新N件）
  Future<List<Topic>> getRecentTopics({int limit = 30}) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Topic.fromJson(_convertFirestoreData(doc.data())))
          .toList();
    } catch (e) {
      print('Error getting recent topics: $e');
      return [];
    }
  }

  /// 今日のトピックが存在するか確認
  Future<bool> hasTodayTopic() async {
    final topic = await getTodayTopic();
    return topic != null;
  }

  /// トピックを削除（管理用）
  Future<void> deleteTopic(String dateKey) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(dateKey)
          .delete();
    } catch (e) {
      print('Error deleting topic: $e');
      rethrow;
    }
  }

  /// トピックにフィードバックを送信
  Future<void> submitFeedback({
    required DateTime date,
    required String userId,
    required String feedbackType, // 'good', 'normal', 'bad'
  }) async {
    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docRef = _firestore.collection(_collectionName).doc(dateKey);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Topic not found');
        }

        final data = snapshot.data()!;
        final feedbackCounts = Map<String, int>.from(data['feedbackCounts'] ?? {});
        final feedbackUsers = Map<String, String>.from(data['feedbackUsers'] ?? {});

        // 既存のフィードバックがある場合は削除
        if (feedbackUsers.containsKey(userId)) {
          final oldFeedback = feedbackUsers[userId]!;
          feedbackCounts[oldFeedback] = (feedbackCounts[oldFeedback] ?? 1) - 1;
          if (feedbackCounts[oldFeedback]! <= 0) {
            feedbackCounts.remove(oldFeedback);
          }
        }

        // 新しいフィードバックを追加
        feedbackUsers[userId] = feedbackType;
        feedbackCounts[feedbackType] = (feedbackCounts[feedbackType] ?? 0) + 1;

        transaction.update(docRef, {
          'feedbackCounts': feedbackCounts,
          'feedbackUsers': feedbackUsers,
        });
      });
    } catch (e) {
      print('Error submitting feedback: $e');
      rethrow;
    }
  }

  /// ユーザーのフィードバックを取得
  Future<String?> getUserFeedback({
    required DateTime date,
    required String userId,
  }) async {
    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final doc = await _firestore
          .collection(_collectionName)
          .doc(dateKey)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      final feedbackUsers = Map<String, String>.from(data['feedbackUsers'] ?? {});
      return feedbackUsers[userId];
    } catch (e) {
      print('Error getting user feedback: $e');
      return null;
    }
  }
}
