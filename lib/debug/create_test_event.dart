import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tyarekyara/feature/debate/models/debate_event.dart';
import 'package:tyarekyara/feature/debate/models/debate_match.dart';

Future<void> createTestEvent() async {
  final firestore = FirebaseFirestore.instance;

  final event = DebateEvent(
    id: 'test_event_001',
    title: 'テストディベート',
    topic: 'AIは人類に有益か',
    description: 'マッチングテスト用イベント',
    status: EventStatus.accepting,
    scheduledAt: DateTime.now().add(Duration(hours: 1)),
    entryDeadline: DateTime.now().add(Duration(hours: 1)),
    availableDurations: [
      DebateDuration.short,
      DebateDuration.medium,
    ],
    availableFormats: [
      DebateFormat.oneVsOne,
      DebateFormat.twoVsTwo,
    ],
    currentParticipants: 0,
    maxParticipants: 100,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  await firestore
      .collection('debate_events')
      .doc(event.id)
      .set(DebateEvent.toFirestore(event));

  debugPrint('✅ テストイベント作成完了: ${event.id}');
}

Future<void> createTestEntries({
  required String eventId,
  required int count,
  required DebateFormat format,
  required DebateDuration duration,
}) async {
  final firestore = FirebaseFirestore.instance;

  for (int i = 0; i < count; i++) {
    final userId = 'test_user_${i + 1}';
    final entryId = '${eventId}_$userId';

    // 立場を交互に設定（最初はpro、次はcon、その後はany）
    final stance = i == 0
        ? DebateStance.pro
        : i == 1
            ? DebateStance.con
            : DebateStance.any;

    final entry = DebateEntry(
      userId: userId,
      eventId: eventId,
      preferredDuration: duration,
      preferredFormat: format,
      preferredStance: stance,
      status: MatchStatus.waiting,
      enteredAt: DateTime.now(),
    );

    await firestore
        .collection('debate_entries')
        .doc(entryId)
        .set(DebateEntry.toFirestore(entry));
  }

  debugPrint('✅ $count 件のテストエントリー作成完了');
}