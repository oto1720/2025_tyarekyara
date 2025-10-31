// 必要な Enum を他のファイルからインポートします
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/challenge_card.dart';

enum Stance {
  pro, // 賛成
  con, // 反対
}

// チャレンジの全情報を保持するクラス
class Challenge {
  final String id;
  final String title;
  final Stance stance;
  final ChallengeDifficulty difficulty;
  // ポイントは difficulty に含まれているので、ここでは不要です

  Challenge({
    required this.id,
    required this.title,
    required this.stance,
    required this.difficulty,
  });
}
