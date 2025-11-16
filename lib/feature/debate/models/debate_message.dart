import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'debate_room.dart';
import 'debate_match.dart';

part 'debate_message.freezed.dart';
part 'debate_message.g.dart';

/// メッセージタイプ
enum MessageType {
  public,   // 公開メッセージ（全員に表示）
  team,     // チーム内秘密チャット
  system,   // システムメッセージ
}

/// メッセージステータス
enum MessageStatus {
  sent,     // 送信済み
  flagged,  // フラグ付き（警告対象）
  deleted,  // 削除済み
}

/// ディベートメッセージ
@freezed
class DebateMessage with _$DebateMessage {
  const factory DebateMessage({
    required String id,
    required String roomId,
    required String userId,
    required String content,
    required MessageType type,
    required DebatePhase phase,
    required DateTime createdAt,
    @Default(MessageStatus.sent) MessageStatus status,
    String? userNickname,
    DebateStance? senderStance,
    bool? isWarning,
    String? flagReason,
    Map<String, dynamic>? metadata,
  }) = _DebateMessage;

  factory DebateMessage.fromJson(Map<String, dynamic> json) {
    return DebateMessage(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.public,
      ),
      phase: DebatePhase.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => DebatePhase.preparation,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      userNickname: json['userNickname'] as String?,
      senderStance: json['senderStance'] != null
          ? DebateStance.values.firstWhere(
              (e) => e.name == json['senderStance'],
              orElse: () => DebateStance.any,
            )
          : null,
      isWarning: json['isWarning'] as bool?,
      flagReason: json['flagReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic> toFirestore(DebateMessage message) {
    return {
      'id': message.id,
      'roomId': message.roomId,
      'userId': message.userId,
      'content': message.content,
      'type': message.type.name,
      'phase': message.phase.name,
      'createdAt': Timestamp.fromDate(message.createdAt),
      'status': message.status.name,
      'userNickname': message.userNickname,
      'senderStance': message.senderStance?.name,
      'isWarning': message.isWarning,
      'flagReason': message.flagReason,
      'metadata': message.metadata,
    };
  }
}

/// メッセージ制限設定
@freezed
class MessageLimits with _$MessageLimits {
  const factory MessageLimits({
    @Default(200) int maxCharacters,
    @Default({}) Map<DebatePhase, int> maxMessagesPerPhase,
    @Default(3) int maxWarnings,
    @Default(30) int cooldownSeconds,
  }) = _MessageLimits;

  factory MessageLimits.fromJson(Map<String, dynamic> json) =>
      _$MessageLimitsFromJson(json);
}

/// DebateMessage拡張
extension DebateMessageExtension on DebateMessage {
  /// ユーザー名取得（nicknameまたはデフォルト値）
  String? get userName => userNickname;

  /// 警告フラグがあるか
  bool get hasWarning => isWarning ?? false;
}
