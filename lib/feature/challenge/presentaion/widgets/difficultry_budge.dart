import 'package:flutter/material.dart';

// 1. 難易度を「型」として定義します (Enum)
//    こうすると、'簡単' のように文字列で渡すよりタイプミスが防げて安全です。
enum ChallengeDifficulty {
  easy, // 簡単
  normal, // 普通
  hard, // 難しい
}

// 2. 難易度バッジを表示する専用のウィジェット
class DifficultyBadge extends StatelessWidget {
  // 呼び出し元から 難易度 を受け取ります
  final ChallengeDifficulty difficulty;

  const DifficultyBadge({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    // 難易度に応じて、表示するテキストと色を決定します
    final (String text, Color color) badgeStyle;

    switch (difficulty) {
      case ChallengeDifficulty.easy:
        badgeStyle = ('簡単', Colors.green);
        break;
      case ChallengeDifficulty.normal:
        badgeStyle = ('普通', Colors.blue);
        break;
      case ChallengeDifficulty.hard:
        badgeStyle = ('難しい', Colors.red);
        break;
    }

    // 3. バッジの見た目（デザイン）
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeStyle.$2.withOpacity(0.15), // 色の薄い背景
        borderRadius: BorderRadius.circular(20), // 楕円形（カプセル型）にする
      ),
      child: Text(
        badgeStyle.$1, // '簡単', '普通', '難しい' のテキスト
        style: TextStyle(
          color: badgeStyle.$2, // 色の濃いテキスト
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
