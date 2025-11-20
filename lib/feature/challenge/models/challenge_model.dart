import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

enum Stance {
  @JsonValue('pro')
  pro, // 賛成
  @JsonValue('con')
  con, // 反対
}

enum ChallengeStatus {
  @JsonValue('available')
  available, // 挑戦可能
  @JsonValue('completed')
  completed, // 完了済み
}

/// チャレンジモデル（Freezed使用）
@Freezed(toJson: true, fromJson: true)
class Challenge with _$Challenge {
  const Challenge._(); // プライベートコンストラクタ（カスタムメソッド用）

  const factory Challenge({
    required String id,
    required String title,
    required Stance stance, // チャレンジで取るべき立場
    Stance? originalStance, // 元の意見の立場
    required ChallengeDifficulty difficulty,
    @Default(ChallengeStatus.available) ChallengeStatus status,
    required String originalOpinionText, // 元の意見
    String? oppositeOpinionText, // チャレンジによる反対の意見
    required String userId,
    DateTime? completedAt, // 完了日時
    int? earnedPoints, // 獲得ポイント
    String? opinionId, // 元の意見ID
  }) = _Challenge;

  /// Firestoreから読み込む際のファクトリ
  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);

  /// Firestoreから読み込む際のファクトリ（Timestamp変換あり）
  factory Challenge.fromFirestore(Map<String, dynamic> json) {
    // Timestamp型の変換処理
    if (json['completedAt'] is Timestamp) {
      json['completedAt'] = (json['completedAt'] as Timestamp).toDate().toIso8601String();
    }
    return _$ChallengeFromJson(json);
  }

  /// Firestoreへ保存する際のカスタムtoJson
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // DateTime を Timestamp に変換
    if (completedAt != null) {
      json['completedAt'] = Timestamp.fromDate(completedAt!);
    }
    return json;
  }

  /// チャレンジが完了しているかどうか
  bool get isCompleted => status == ChallengeStatus.completed;

  /// チャレンジが利用可能かどうか
  bool get isAvailable => status == ChallengeStatus.available;
}
