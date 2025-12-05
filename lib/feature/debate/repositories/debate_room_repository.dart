import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debate_room.dart';
import '../models/debate_message.dart';
import '../models/debate_match.dart';
import '../models/judgment_result.dart';
import 'package:flutter/foundation.dart';
/// ディベートルームリポジトリ
class DebateRoomRepository {
  final FirebaseFirestore _firestore;
  static const String _roomsCollectionName = 'debate_rooms';
  static const String _messagesCollectionName = 'messages';
  static const String _judgmentsCollectionName = 'debate_judgments';

  DebateRoomRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ルームを取得
  Future<DebateRoom?> getRoom(String roomId) async {
    try {
      final doc = await _firestore
          .collection(_roomsCollectionName)
          .doc(roomId)
          .get();

      if (!doc.exists) return null;
      return DebateRoom.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting room: $e');
      return null;
    }
  }

  /// ルームをリアルタイム監視
  Stream<DebateRoom?> watchRoom(String roomId) {
    return _firestore
        .collection(_roomsCollectionName)
        .doc(roomId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return DebateRoom.fromJson(doc.data()!);
    });
  }

  /// マッチIDからルームを取得
  Future<DebateRoom?> getRoomByMatchId(String matchId) async {
    try {
      final snapshot = await _firestore
          .collection(_roomsCollectionName)
          .where('matchId', isEqualTo: matchId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return DebateRoom.fromJson(snapshot.docs.first.data());
    } catch (e) {
      debugPrint('Error getting room by match ID: $e');
      return null;
    }
  }

  /// マッチIDからルームをリアルタイム監視
  Stream<DebateRoom?> watchRoomByMatchId(String matchId) {
    return _firestore
        .collection(_roomsCollectionName)
        .where('matchId', isEqualTo: matchId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return DebateRoom.fromJson(snapshot.docs.first.data());
    });
  }

  /// メッセージを送信
  Future<void> sendMessage(DebateMessage message) async {
    try {
      await _firestore
          .collection(_roomsCollectionName)
          .doc(message.roomId)
          .collection(_messagesCollectionName)
          .doc(message.id)
          .set(DebateMessage.toFirestore(message));
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  /// メッセージ一覧をリアルタイム監視
  Stream<List<DebateMessage>> watchMessages(
    String roomId, {
    MessageType? type,
    DebateStance? senderStance,
  }) {
    Query query = _firestore
        .collection(_roomsCollectionName)
        .doc(roomId)
        .collection(_messagesCollectionName)
        .orderBy('createdAt', descending: false);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (senderStance != null) {
      query = query.where('senderStance', isEqualTo: senderStance.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DebateMessage.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// 特定フェーズのメッセージを取得
  Future<List<DebateMessage>> getMessagesByPhase(
    String roomId,
    DebatePhase phase,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_roomsCollectionName)
          .doc(roomId)
          .collection(_messagesCollectionName)
          .where('phase', isEqualTo: phase.name)
          .where('type', isEqualTo: MessageType.public.name)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => DebateMessage.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting messages by phase: $e');
      return [];
    }
  }

  /// 全メッセージを取得（AI判定用）
  Future<List<DebateMessage>> getAllMessages(String roomId) async {
    try {
      final snapshot = await _firestore
          .collection(_roomsCollectionName)
          .doc(roomId)
          .collection(_messagesCollectionName)
          .where('type', isEqualTo: MessageType.public.name)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => DebateMessage.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting all messages: $e');
      return [];
    }
  }

  /// ルームを更新
  Future<void> updateRoom(DebateRoom room) async {
    try {
      await _firestore
          .collection(_roomsCollectionName)
          .doc(room.id)
          .update(DebateRoom.toFirestore(room));
    } catch (e) {
      debugPrint('Error updating room: $e');
      rethrow;
    }
  }

  /// フェーズを更新
  Future<void> updatePhase(
    String roomId,
    DebatePhase phase,
    int timeRemaining,
  ) async {
    try {
      await _firestore
          .collection(_roomsCollectionName)
          .doc(roomId)
          .update({
        'currentPhase': phase.name,
        'phaseStartedAt': Timestamp.now(),
        'phaseTimeRemaining': timeRemaining,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error updating phase: $e');
      rethrow;
    }
  }

  /// 警告カウントを更新
  Future<void> updateWarningCount(String roomId, String userId) async {
    try {
      await _firestore
          .collection(_roomsCollectionName)
          .doc(roomId)
          .update({
        'warningCount.$userId': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error updating warning count: $e');
      rethrow;
    }
  }

  /// 判定結果を保存
  Future<void> saveJudgment(JudgmentResult judgment) async {
    try {
      await _firestore
          .collection(_judgmentsCollectionName)
          .doc(judgment.id)
          .set(JudgmentResult.toFirestore(judgment));
    } catch (e) {
      debugPrint('Error saving judgment: $e');
      rethrow;
    }
  }

  /// 判定結果を取得
  Future<JudgmentResult?> getJudgment(String judgmentId) async {
    try {
      final doc = await _firestore
          .collection(_judgmentsCollectionName)
          .doc(judgmentId)
          .get();

      if (!doc.exists) return null;
      return JudgmentResult.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error getting judgment: $e');
      return null;
    }
  }

  /// マッチIDから判定結果を取得
  Future<JudgmentResult?> getJudgmentByMatchId(String matchId) async {
    try {
      final snapshot = await _firestore
          .collection(_judgmentsCollectionName)
          .where('matchId', isEqualTo: matchId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return JudgmentResult.fromJson(snapshot.docs.first.data());
    } catch (e) {
      debugPrint('Error getting judgment by match ID: $e');
      return null;
    }
  }
}
