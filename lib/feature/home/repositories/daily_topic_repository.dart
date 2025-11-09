import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic.dart';

/// 日別トピックをFirestoreで管理するリポジトリ
class DailyTopicRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'daily_topics';

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
        final data = doc.data()!;
        return Topic.fromJson(data);
      }
      return null;
    } catch (e) {
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
        return Topic.fromJson(doc.data()!);
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
          .map((doc) => Topic.fromJson(doc.data()))
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
}
