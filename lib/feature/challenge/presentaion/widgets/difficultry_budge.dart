import 'package:flutter/material.dart';

// 1. Enumを修正し、テキスト、色、ポイントの情報をそれぞれに持たせる
enum ChallengeDifficulty {
  easy('簡単', Colors.green, 30),
  normal('普通', Colors.amber, 50),
  hard('難しい', Colors.red, 100);

  // Enumが持つプロパティを定義
  final String label;
  final Color color;
  final int points;

  // コンストラクタ
  const ChallengeDifficulty(this.label, this.color, this.points);
}

// 2. 難易度バッジを表示する専用のウィジェット
class DifficultyBadge extends StatelessWidget {
  final ChallengeDifficulty difficulty;
  // 3. ポイントも表示するかどうかを制御するフラグを追加（デフォルトは false）
  final bool showPoints;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showPoints = false, // デフォルトはポイント非表示
  });

  @override
  Widget build(BuildContext context) {
    // 難易度バッジの本体
    final difficultyTag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        // 1. 背景色を透明にする
        color: Colors.transparent,

        // 2. 枠線を追加する
        border: Border.all(
          color: difficulty.color, // Enumから取得した色を枠線に使う
          width: 1.5, // 枠線の太さ（お好みで調整してください）
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty.label, // Enumからテキストを取得
        style: TextStyle(
          color: difficulty.color, // Enumから色を取得
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );

    // 4. showPoints が false なら、難易度バッジだけを返す
    if (!showPoints) {
      return difficultyTag;
    }

    // 5. showPoints が true なら、ポイントバッジも作って Row で並べて返す
    final pointsTag = Text(
      '+${difficulty.points} P', // Enumからポイントを取得
      style: TextStyle(
        color: difficulty.color, // 難易度と同じ色を使う
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    // 難易度とポイントを横に並べる
    return Row(
      mainAxisSize: MainAxisSize.min, // 必要な分だけ幅をとる
      children: [difficultyTag, const SizedBox(width: 8), pointsTag],
    );
  }
}
