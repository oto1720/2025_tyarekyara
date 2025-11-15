import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'debate_match.dart';

part 'debate_room.freezed.dart';

/// ディベートフェーズ
enum DebatePhase {
  preparation,      // 準備時間
  openingPro,      // 立論（賛成）
  openingCon,      // 立論（反対）
  questionPro,     // 質疑応答（賛成への質問）
  questionCon,     // 質疑応答（反対への質問）
  rebuttalPro,     // 反論（賛成）
  rebuttalCon,     // 反論（反対）
  closingPro,      // 最終主張（賛成）
  closingCon,      // 最終主張（反対）
  judgment,        // AI判定中
  result,          // 結果表示
  completed,       // 完了
}

extension DebatePhaseExtension on DebatePhase {
  String get displayName {
    switch (this) {
      case DebatePhase.preparation:
        return '準備時間';
      case DebatePhase.openingPro:
        return '立論（賛成）';
      case DebatePhase.openingCon:
        return '立論（反対）';
      case DebatePhase.questionPro:
        return '質疑応答（賛成へ）';
      case DebatePhase.questionCon:
        return '質疑応答（反対へ）';
      case DebatePhase.rebuttalPro:
        return '反論（賛成）';
      case DebatePhase.rebuttalCon:
        return '反論（反対）';
      case DebatePhase.closingPro:
        return '最終主張（賛成）';
      case DebatePhase.closingCon:
        return '最終主張（反対）';
      case DebatePhase.judgment:
        return 'AI判定中';
      case DebatePhase.result:
        return '結果発表';
      case DebatePhase.completed:
        return '完了';
    }
  }

  /// 5分モードの時間（秒）
  int get shortDuration {
    switch (this) {
      case DebatePhase.preparation:
        return 30;
      case DebatePhase.openingPro:
      case DebatePhase.openingCon:
        return 60;
      case DebatePhase.rebuttalPro:
      case DebatePhase.rebuttalCon:
        return 45;
      case DebatePhase.closingPro:
      case DebatePhase.closingCon:
        return 30;
      case DebatePhase.judgment:
        return 15;
      default:
        return 0;
    }
  }

  /// 10分モードの時間（秒）
  int get mediumDuration {
    switch (this) {
      case DebatePhase.preparation:
        return 60;
      case DebatePhase.openingPro:
      case DebatePhase.openingCon:
        return 90;
      case DebatePhase.questionPro:
      case DebatePhase.questionCon:
        return 30;
      case DebatePhase.rebuttalPro:
      case DebatePhase.rebuttalCon:
        return 60;
      case DebatePhase.closingPro:
      case DebatePhase.closingCon:
        return 45;
      case DebatePhase.judgment:
        return 20;
      default:
        return 0;
    }
  }
}

/// ディベートルーム状態
enum RoomStatus {
  waiting,     // 開始待ち
  inProgress,  // 進行中
  judging,     // 判定中
  completed,   // 完了
  abandoned,   // 中断
}

/// ディベートルーム
@freezed
class DebateRoom with _$DebateRoom {
  const factory DebateRoom({
    required String id,
    required String eventId,
    required String matchId,
    required List<String> participantIds,
    required Map<String, DebateStance> participantStances,
    required RoomStatus status,
    required DebatePhase currentPhase,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? phaseStartedAt,
    @Default(0) int phaseTimeRemaining,
    @Default({}) Map<String, int> messageCount,
    @Default({}) Map<String, int> warningCount,
    String? judgmentId,
    Map<String, dynamic>? metadata,
  }) = _DebateRoom;

  factory DebateRoom.fromJson(Map<String, dynamic> json) {
    return DebateRoom(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      matchId: json['matchId'] as String,
      participantIds: (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participantStances: (json['participantStances'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
                key,
                DebateStance.values.firstWhere(
                  (e) => e.name == value,
                  orElse: () => DebateStance.any,
                ),
              )),
      status: RoomStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoomStatus.waiting,
      ),
      currentPhase: DebatePhase.values.firstWhere(
        (e) => e.name == json['currentPhase'],
        orElse: () => DebatePhase.preparation,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      startedAt: json['startedAt'] != null
          ? (json['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      phaseStartedAt: json['phaseStartedAt'] != null
          ? (json['phaseStartedAt'] as Timestamp).toDate()
          : null,
      phaseTimeRemaining: json['phaseTimeRemaining'] as int? ?? 0,
      messageCount: (json['messageCount'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          {},
      warningCount: (json['warningCount'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          {},
      judgmentId: json['judgmentId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic> toFirestore(DebateRoom room) {
    return {
      'id': room.id,
      'eventId': room.eventId,
      'matchId': room.matchId,
      'participantIds': room.participantIds,
      'participantStances':
          room.participantStances.map((key, value) => MapEntry(key, value.name)),
      'status': room.status.name,
      'currentPhase': room.currentPhase.name,
      'createdAt': Timestamp.fromDate(room.createdAt),
      'updatedAt': Timestamp.fromDate(room.updatedAt),
      'startedAt':
          room.startedAt != null ? Timestamp.fromDate(room.startedAt!) : null,
      'completedAt': room.completedAt != null
          ? Timestamp.fromDate(room.completedAt!)
          : null,
      'phaseStartedAt': room.phaseStartedAt != null
          ? Timestamp.fromDate(room.phaseStartedAt!)
          : null,
      'phaseTimeRemaining': room.phaseTimeRemaining,
      'messageCount': room.messageCount,
      'warningCount': room.warningCount,
      'judgmentId': room.judgmentId,
      'metadata': room.metadata,
    };
  }
}
