// 必要な Enum を他のファイルからインポートします
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
  final Stance stance;
  final ChallengeDifficulty difficulty;
  // ポイントは difficulty に含まれているので、ここでは不要です
  ChallengeStatus status;
  final String originalOpinionText; //元の意見
  String? oppositeOpinionText;  //チャレンジによる反対の意見

  Challenge({
    required this.id,
    required this.title,
    required this.stance,
    required this.difficulty,
    this.status = ChallengeStatus.available,
    required this.originalOpinionText,
    this.oppositeOpinionText, // 初期値は null
  });
}
