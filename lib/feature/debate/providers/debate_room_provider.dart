import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debate_room.dart';
import '../models/debate_message.dart';
import '../models/judgment_result.dart';
import '../repositories/debate_room_repository.dart';

/// DebateRoomRepository Provider
final debateRoomRepositoryProvider = Provider<DebateRoomRepository>((ref) {
  return DebateRoomRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// ルーム詳細 Provider
final roomDetailProvider = StreamProvider.autoDispose.family<DebateRoom?, String>(
  (ref, roomId) {
    final repository = ref.watch(debateRoomRepositoryProvider);
    return repository.watchRoom(roomId);
  },
);

/// ルームメッセージ一覧 Provider
final roomMessagesProvider = StreamProvider.autoDispose.family<List<DebateMessage>, String>(
  (ref, roomId) {
    final repository = ref.watch(debateRoomRepositoryProvider);
    return repository.watchMessages(roomId);
  },
);

/// チーム内メッセージ Provider
final teamMessagesProvider = StreamProvider.autoDispose.family<List<DebateMessage>, String>(
  (ref, roomId) {
    final repository = ref.watch(debateRoomRepositoryProvider);
    return repository.watchMessages(roomId, type: MessageType.team);
  },
);

/// マッチIDからルーム取得 Provider
final debateRoomByMatchProvider = FutureProvider.autoDispose.family<DebateRoom?, String>(
  (ref, matchId) async {
    final repository = ref.watch(debateRoomRepositoryProvider);
    return await repository.getRoomByMatchId(matchId);
  },
);

/// メッセージタイプ別メッセージ Provider
final debateMessagesProvider = StreamProvider.autoDispose.family<List<DebateMessage>, (String, MessageType)>(
  (ref, params) {
    final (roomId, messageType) = params;
    final repository = ref.watch(debateRoomRepositoryProvider);
    return repository.watchMessages(roomId, type: messageType);
  },
);

/// 判定結果 Provider
final judgmentResultProvider = FutureProvider.autoDispose.family<JudgmentResult?, String>(
  (ref, matchId) async {
    final repository = ref.watch(debateRoomRepositoryProvider);
    return await repository.getJudgmentByMatchId(matchId);
  },
);
