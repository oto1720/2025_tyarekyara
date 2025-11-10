// 必要な Enum を他のファイルからインポートします
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';


enum Stance {
  pro, // 賛成
  con, // 反対
}

enum ChallengeStatus {
  available, // 挑戦可能
  completed, // 完了済み
}

// チャレンジの全情報を保持するクラス
class Challenge {
  final String id;
  final String title;
  final Stance stance; // チャレンジで取るべき立場（反対の立場）
  final Stance? originalStance; // 元の意見の立場
  final ChallengeDifficulty difficulty;
  // ポイントは difficulty に含まれているので、ここでは不要です
  ChallengeStatus status;
  final String originalOpinionText; //元の意見
  String? oppositeOpinionText;  //チャレンジによる反対の意見
  final String userId; // ユーザーID
  final DateTime? completedAt; // 完了日時
  final int? earnedPoints; // 獲得ポイント
  final String? opinionId; // 元の意見ID（ホームで投稿した意見との紐付け）

  Challenge({
    required this.id,
    required this.title,
    required this.stance,
    this.originalStance, // オプショナル（ダミーデータの場合はnull）
    required this.difficulty,
    this.status = ChallengeStatus.available,
    required this.originalOpinionText,
    this.oppositeOpinionText, // 初期値は null
    required this.userId,
    this.completedAt,
    this.earnedPoints,
    this.opinionId, // オプショナル（ダミーデータ用）
  });

  // Firestoreへの保存用
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'stance': stance.name,
      'originalStance': originalStance?.name,
      'difficulty': difficulty.name,
      'status': status.name,
      'originalOpinionText': originalOpinionText,
      'oppositeOpinionText': oppositeOpinionText,
      'userId': userId,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'earnedPoints': earnedPoints,
      'opinionId': opinionId,
    };
  }

  // Firestoreからの読み込み用
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      stance: Stance.values.firstWhere((e) => e.name == json['stance']),
      originalStance: json['originalStance'] != null
          ? Stance.values.firstWhere((e) => e.name == json['originalStance'])
          : null,
      difficulty: ChallengeDifficulty.values.firstWhere((e) => e.name == json['difficulty']),
      status: ChallengeStatus.values.firstWhere((e) => e.name == json['status']),
      originalOpinionText: json['originalOpinionText'] as String,
      oppositeOpinionText: json['oppositeOpinionText'] as String?,
      userId: json['userId'] as String,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      earnedPoints: json['earnedPoints'] as int?,
      opinionId: json['opinionId'] as String?,
    );
  }
}
