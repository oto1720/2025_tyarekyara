import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'debate_event.dart';

part 'debate_match.freezed.dart';
part 'debate_match.g.dart';

/// マッチング状態
enum MatchStatus {
  waiting,    // 待機中
  matched,    // マッチング成立
  inProgress, // 進行中
  completed,  // 完了
  cancelled,  // キャンセル
}

/// 立場
enum DebateStance {
  pro,     // 賛成
  con,     // 反対
  any,     // どちらでも可
}

extension DebateStanceExtension on DebateStance {
  String get displayName {
    switch (this) {
      case DebateStance.pro:
        return '賛成';
      case DebateStance.con:
        return '反対';
      case DebateStance.any:
        return 'どちらでも可';
    }
  }
}

/// エントリー設定
@freezed
class DebateEntry with _$DebateEntry {
  const factory DebateEntry({
    required String userId,
    required String eventId,
    required DebateDuration preferredDuration,
    required DebateFormat preferredFormat,
    required DebateStance preferredStance,
    required DateTime enteredAt,
    @Default(MatchStatus.waiting) MatchStatus status,
    String? matchId,
  }) = _DebateEntry;

  factory DebateEntry.fromJson(Map<String, dynamic> json) {
    return DebateEntry(
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      preferredDuration: DebateDuration.values.firstWhere(
        (e) => e.name == json['preferredDuration'],
        orElse: () => DebateDuration.medium,
      ),
      preferredFormat: DebateFormat.values.firstWhere(
        (e) => e.name == json['preferredFormat'],
        orElse: () => DebateFormat.twoVsTwo,
      ),
      preferredStance: DebateStance.values.firstWhere(
        (e) => e.name == json['preferredStance'],
        orElse: () => DebateStance.any,
      ),
      enteredAt: (json['enteredAt'] as Timestamp).toDate(),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchStatus.waiting,
      ),
      matchId: json['matchId'] as String?,
    );
  }

  static Map<String, dynamic> toFirestore(DebateEntry entry) {
    return {
      'userId': entry.userId,
      'eventId': entry.eventId,
      'preferredDuration': entry.preferredDuration.name,
      'preferredFormat': entry.preferredFormat.name,
      'preferredStance': entry.preferredStance.name,
      'enteredAt': Timestamp.fromDate(entry.enteredAt),
      'status': entry.status.name,
      'matchId': entry.matchId,
    };
  }
}

/// チーム
@freezed
class DebateTeam with _$DebateTeam {
  const factory DebateTeam({
    required DebateStance stance,
    required List<String> memberIds,
    @Default(0) int score,
    String? mvpUserId,
  }) = _DebateTeam;

  factory DebateTeam.fromJson(Map<String, dynamic> json) =>
      _$DebateTeamFromJson(json);
}

/// マッチング情報
@freezed
class DebateMatch with _$DebateMatch {
  const factory DebateMatch({
    required String id,
    required String eventId,
    required DebateFormat format,
    required DebateDuration duration,
    required DebateTeam proTeam,
    required DebateTeam conTeam,
    required MatchStatus status,
    required DateTime matchedAt,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? roomId,
    String? winningSide,
    Map<String, dynamic>? metadata,
  }) = _DebateMatch;

  factory DebateMatch.fromJson(Map<String, dynamic> json) {
    return DebateMatch(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      format: DebateFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => DebateFormat.twoVsTwo,
      ),
      duration: DebateDuration.values.firstWhere(
        (e) => e.name == json['duration'],
        orElse: () => DebateDuration.medium,
      ),
      proTeam: DebateTeam.fromJson(json['proTeam'] as Map<String, dynamic>),
      conTeam: DebateTeam.fromJson(json['conTeam'] as Map<String, dynamic>),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchStatus.matched,
      ),
      matchedAt: (json['matchedAt'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      startedAt: json['startedAt'] != null
          ? (json['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      roomId: json['roomId'] as String?,
      winningSide: json['winningSide'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic> toFirestore(DebateMatch match) {
    return {
      'id': match.id,
      'eventId': match.eventId,
      'format': match.format.name,
      'duration': match.duration.name,
      'proTeam': {
        'stance': match.proTeam.stance.name,
        'memberIds': match.proTeam.memberIds,
        'score': match.proTeam.score,
        'mvpUserId': match.proTeam.mvpUserId,
      },
      'conTeam': {
        'stance': match.conTeam.stance.name,
        'memberIds': match.conTeam.memberIds,
        'score': match.conTeam.score,
        'mvpUserId': match.conTeam.mvpUserId,
      },
      'status': match.status.name,
      'matchedAt': Timestamp.fromDate(match.matchedAt),
      'createdAt': Timestamp.fromDate(match.createdAt),
      'startedAt':
          match.startedAt != null ? Timestamp.fromDate(match.startedAt!) : null,
      'completedAt': match.completedAt != null
          ? Timestamp.fromDate(match.completedAt!)
          : null,
      'roomId': match.roomId,
      'winningSide': match.winningSide,
      'metadata': match.metadata,
    };
  }
}
