import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'debate_match.dart';

part 'judgment_result.freezed.dart';
part 'judgment_result.g.dart';

/// 評価項目
enum JudgmentCriteria {
  logic,         // 論理性
  evidence,      // 根拠の強さ
  rebuttal,      // 反論の的確さ
  persuasiveness, // 説得力
  manner,        // マナー
}

extension JudgmentCriteriaExtension on JudgmentCriteria {
  String get displayName {
    switch (this) {
      case JudgmentCriteria.logic:
        return '論理性';
      case JudgmentCriteria.evidence:
        return '根拠の強さ';
      case JudgmentCriteria.rebuttal:
        return '反論の的確さ';
      case JudgmentCriteria.persuasiveness:
        return '説得力';
      case JudgmentCriteria.manner:
        return 'マナー';
    }
  }

  String get description {
    switch (this) {
      case JudgmentCriteria.logic:
        return '主張の筋道が通っているか';
      case JudgmentCriteria.evidence:
        return '具体例やデータの提示';
      case JudgmentCriteria.rebuttal:
        return '相手の主張への対応';
      case JudgmentCriteria.persuasiveness:
        return '表現の明確さ';
      case JudgmentCriteria.manner:
        return '礼儀正しさ、冷静さ';
    }
  }
}

/// チームスコア
@freezed
class TeamScore with _$TeamScore {
  const factory TeamScore({
    required DebateStance stance,
    @Default(0) int logic,
    @Default(0) int evidence,
    @Default(0) int rebuttal,
    @Default(0) int persuasiveness,
    @Default(0) int manner,
    @Default(0) int total,
    // エイリアス（Cloud Functions互換用）
    @Default(0) int logicScore,
    @Default(0) int evidenceScore,
    @Default(0) int rebuttalScore,
    @Default(0) int persuasivenessScore,
    @Default(0) int mannerScore,
    @Default(0) int totalScore,
    String? feedback,
  }) = _TeamScore;

  factory TeamScore.fromJson(Map<String, dynamic> json) =>
      _$TeamScoreFromJson(json);
}

/// 個人評価
@freezed
class IndividualEvaluation with _$IndividualEvaluation {
  const factory IndividualEvaluation({
    required String userId,
    required String userNickname,
    required DebateStance stance,
    @Default(0) int contributionScore,
    @Default([]) List<String> strengths,
    @Default([]) List<String> improvements,
    @Default(false) bool isMvp,
  }) = _IndividualEvaluation;

  factory IndividualEvaluation.fromJson(Map<String, dynamic> json) =>
      _$IndividualEvaluationFromJson(json);
}

/// AI判定結果
@freezed
class JudgmentResult with _$JudgmentResult {
  const factory JudgmentResult({
    required String id,
    required String roomId,
    required String matchId,
    required TeamScore proTeamScore,
    required TeamScore conTeamScore,
    DebateStance? winningSide,
    required String summary,
    required DateTime judgedAt,
    required DateTime createdAt,
    @Default([]) List<IndividualEvaluation> individualEvaluations,
    String? mvpUserId,
    String? keyMoment,
    // Cloud Functions互換用コメント
    String? overallComment,
    String? proTeamComment,
    String? conTeamComment,
    Map<String, dynamic>? aiMetadata,
  }) = _JudgmentResult;

  factory JudgmentResult.fromJson(Map<String, dynamic> json) {
    return JudgmentResult(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      matchId: json['matchId'] as String,
      proTeamScore:
          TeamScore.fromJson(json['proTeamScore'] as Map<String, dynamic>),
      conTeamScore:
          TeamScore.fromJson(json['conTeamScore'] as Map<String, dynamic>),
      winningSide: json['winningSide'] != null
          ? DebateStance.values.firstWhere(
              (e) => e.name == json['winningSide'],
              orElse: () => DebateStance.pro,
            )
          : null,
      summary: json['summary'] as String,
      judgedAt: (json['judgedAt'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      individualEvaluations: (json['individualEvaluations'] as List<dynamic>?)
              ?.map((e) =>
                  IndividualEvaluation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mvpUserId: json['mvpUserId'] as String?,
      keyMoment: json['keyMoment'] as String?,
      overallComment: json['overallComment'] as String?,
      proTeamComment: json['proTeamComment'] as String?,
      conTeamComment: json['conTeamComment'] as String?,
      aiMetadata: json['aiMetadata'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic> toFirestore(JudgmentResult result) {
    return {
      'id': result.id,
      'roomId': result.roomId,
      'matchId': result.matchId,
      'proTeamScore': {
        'stance': result.proTeamScore.stance.name,
        'logic': result.proTeamScore.logic,
        'evidence': result.proTeamScore.evidence,
        'rebuttal': result.proTeamScore.rebuttal,
        'persuasiveness': result.proTeamScore.persuasiveness,
        'manner': result.proTeamScore.manner,
        'total': result.proTeamScore.total,
        'feedback': result.proTeamScore.feedback,
      },
      'conTeamScore': {
        'stance': result.conTeamScore.stance.name,
        'logic': result.conTeamScore.logic,
        'evidence': result.conTeamScore.evidence,
        'rebuttal': result.conTeamScore.rebuttal,
        'persuasiveness': result.conTeamScore.persuasiveness,
        'manner': result.conTeamScore.manner,
        'total': result.conTeamScore.total,
        'feedback': result.conTeamScore.feedback,
      },
      'winningSide': result.winningSide?.name,
      'summary': result.summary,
      'judgedAt': Timestamp.fromDate(result.judgedAt),
      'createdAt': Timestamp.fromDate(result.createdAt),
      'individualEvaluations': result.individualEvaluations
          .map((e) => {
                'userId': e.userId,
                'userNickname': e.userNickname,
                'stance': e.stance.name,
                'contributionScore': e.contributionScore,
                'strengths': e.strengths,
                'improvements': e.improvements,
                'isMvp': e.isMvp,
              })
          .toList(),
      'mvpUserId': result.mvpUserId,
      'keyMoment': result.keyMoment,
      'overallComment': result.overallComment,
      'proTeamComment': result.proTeamComment,
      'conTeamComment': result.conTeamComment,
      'aiMetadata': result.aiMetadata,
    };
  }
}
