import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';

part 'challenge_state.freezed.dart';

/// チャレンジ状態モデル（Freezed使用）
@freezed
class ChallengeState with _$ChallengeState {
  const factory ChallengeState({
    @Default([]) List<Challenge> challenges,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ChallengeState;

  const ChallengeState._(); // カスタムメソッド用

  /// エラーがあるかどうか
  bool get hasError => errorMessage != null;

  /// データが存在するかどうか
  bool get hasData => challenges.isNotEmpty;

  /// 完了済みのチャレンジ数
  int get completedCount =>
      challenges.where((c) => c.status == ChallengeStatus.completed).length;

  /// 利用可能なチャレンジ数
  int get availableCount =>
      challenges.where((c) => c.status == ChallengeStatus.available).length;
}
