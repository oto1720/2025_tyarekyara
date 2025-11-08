import 'package:freezed_annotation/freezed_annotation.dart';

part 'opinion.freezed.dart';
part 'opinion.g.dart';

/// 意見の立場
enum OpinionStance {
  @JsonValue('agree')
  agree, // 賛成
  @JsonValue('disagree')
  disagree, // 反対
  @JsonValue('neutral')
  neutral, // 中立
}

/// リアクションの種類
enum ReactionType {
  @JsonValue('empathy')
  empathy, // 共感した
  @JsonValue('thoughtful')
  thoughtful, // 考えさせられた
  @JsonValue('newPerspective')
  newPerspective, // 新しい視点
}

/// 意見モデル
@freezed
class Opinion with _$Opinion {
  const factory Opinion({
    required String id,
    required String topicId, // トピックID
    required String topicText, // トピックのテキスト（表示用）
    required String userId, // 投稿者のUID
    required String userName, // 投稿者の名前
    required OpinionStance stance, // 立場
    required String content, // 意見の内容
    required DateTime createdAt, // 投稿日時
    @Default(0) int likeCount, // いいね数
    @Default(false) bool isDeleted, // 削除フラグ
    // リアクション機能
    @Default({
      'empathy': 0,
      'thoughtful': 0,
      'newPerspective': 0,
    })
    Map<String, int> reactionCounts, // リアクション数
    @Default({
      'empathy': [],
      'thoughtful': [],
      'newPerspective': [],
    })
    Map<String, List<String>> reactedUsers, // リアクションしたユーザーのUID
  }) = _Opinion;

  factory Opinion.fromJson(Map<String, dynamic> json) =>
      _$OpinionFromJson(json);
}

/// 立場の日本語名を取得
extension OpinionStanceExtension on OpinionStance {
  String get displayName {
    switch (this) {
      case OpinionStance.agree:
        return '賛成';
      case OpinionStance.disagree:
        return '反対';
      case OpinionStance.neutral:
        return '中立';
    }
  }

  String get emoji {
    switch (this) {
      case OpinionStance.agree:
        return '👍';
      case OpinionStance.disagree:
        return '👎';
      case OpinionStance.neutral:
        return '🤔';
    }
  }
}

/// リアクションの表示名とアイコンを取得
extension ReactionTypeExtension on ReactionType {
  String get displayName {
    switch (this) {
      case ReactionType.empathy:
        return '共感した';
      case ReactionType.thoughtful:
        return '考えさせられた';
      case ReactionType.newPerspective:
        return '新しい視点';
    }
  }

  String get emoji {
    switch (this) {
      case ReactionType.empathy:
        return '💙';
      case ReactionType.thoughtful:
        return '💭';
      case ReactionType.newPerspective:
        return '💡';
    }
  }

  String get key {
    switch (this) {
      case ReactionType.empathy:
        return 'empathy';
      case ReactionType.thoughtful:
        return 'thoughtful';
      case ReactionType.newPerspective:
        return 'newPerspective';
    }
  }
}
