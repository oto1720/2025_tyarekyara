import 'package:flutter/material.dart';
import 'package:tyarekyara/widgets/custom_button.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';

Widget buildStanceTag(String text, Color backgroundColor, Color textColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    decoration: BoxDecoration(
      color: backgroundColor, // 引数で受け取った色
      borderRadius: BorderRadius.circular(4.0), // 少し角丸の四角
    ),
    child: Text(
      text,
      // ↓↓↓ TextStyle の const を外し、引数の textColor を使う
      style: TextStyle(
        color: textColor, // 色付きの背景なので文字は白
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

// チャレンジカード専用のウィジェット
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final Future<void> Function() onChallengePressed;

  // コンストラクタ（呼び出し元から情報を受け取る）
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onChallengePressed,
  });

  @override
  Widget build(BuildContext context) {
    // ゆきさんが作成した Card のレイアウトをそのまま使います
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
          children: [
            // 1行目: 難易度とタイトル
            DifficultyBadge(
              difficulty: challenge.difficulty, // ← 受け取った難易度
              showPoints: true, // ← ポイントも表示
            ),
            const SizedBox(width: 8),
            Text(
              challenge.title, // ← 受け取ったタイトル
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 2行目: 自分と逆の意見を示すタグ
            Row(
              children: [
                const Text('あなた: ', style: TextStyle(fontSize: 14)),

                // stance が pro (賛成) なら緑の「賛成」タグ、con (反対) なら赤の「反対」タグ
                buildStanceTag(
                  challenge.stance == Stance.pro ? '賛成' : '反対',
                  challenge.stance == Stance.pro
                      ? const Color.fromARGB(255, 214, 241, 215)
                      : const Color.fromARGB(255, 249, 209, 213),
                  challenge.stance == Stance.pro
                      ? Colors.green[900]!
                      : Colors.red[900]!,
                ),

                // 矢印アイコン
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),

                const Text('挑戦: ', style: TextStyle(fontSize: 14)),

                // stance が pro (賛成) なら赤の「反対」タグ、con (反対) なら緑の「賛成」タグ
                buildStanceTag(
                  challenge.stance == Stance.pro ? '反対' : '賛成',
                  challenge.stance == Stance.pro
                      ? const Color.fromARGB(255, 249, 209, 213)
                      : const Color.fromARGB(255, 214, 241, 215),
                  challenge.stance == Stance.pro
                      ? Colors.red[900]!
                      : Colors.green[900]!,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4行目: ボタン
            Center(
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: onChallengePressed, // ← 受け取った処理
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                  ),
                  child: const Text(
                    'チャレンジする',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
