import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debate_event.dart';

/// ディベートイベントリポジトリ
class DebateEventRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'debate_events';

  DebateEventRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// イベント一覧を取得（開催予定順）
  Future<List<DebateEvent>> getUpcomingEvents({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('status', whereIn: [
            EventStatus.scheduled.name,
            EventStatus.accepting.name,
            EventStatus.matching.name,
          ])
          .orderBy('scheduledAt', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DebateEvent.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting upcoming events: $e');
      return [];
    }
  }

  /// 過去のイベント一覧を取得
  Future<List<DebateEvent>> getCompletedEvents({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: EventStatus.completed.name)
          .orderBy('scheduledAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DebateEvent.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting completed events: $e');
      return [];
    }
  }

  /// イベント詳細を取得
  Future<DebateEvent?> getEvent(String eventId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(eventId)
          .get();

      if (!doc.exists) return null;
      return DebateEvent.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  /// イベントをリアルタイム監視
  Stream<DebateEvent?> watchEvent(String eventId) {
    return _firestore
        .collection(_collectionName)
        .doc(eventId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return DebateEvent.fromJson(doc.data()!);
    });
  }

  /// 開催予定イベント一覧をリアルタイム監視
  Stream<List<DebateEvent>> watchUpcomingEvents({int limit = 20}) {
    return _firestore
        .collection(_collectionName)
        .where('status', whereIn: [
          EventStatus.scheduled.name,
          EventStatus.accepting.name,
          EventStatus.matching.name,
        ])
        .orderBy('scheduledAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DebateEvent.fromJson(doc.data()))
          .toList();
    });
  }

  /// イベントを作成（管理者機能）
  Future<void> createEvent(DebateEvent event) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(event.id)
          .set(DebateEvent.toFirestore(event));
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  /// イベントを更新
  Future<void> updateEvent(DebateEvent event) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(event.id)
          .update(DebateEvent.toFirestore(event));
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  /// イベントの参加者数を更新
  Future<void> updateParticipantCount(String eventId, int count) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(eventId)
          .update({
        'currentParticipants': count,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating participant count: $e');
      rethrow;
    }
  }
}
