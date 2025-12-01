import 'package:flutter/material.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';

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
class CompletedCard extends StatelessWidget {
  final Challenge challenge;
  final Future<void> Function() onChallengePressed;

  // コンストラクタ（呼び出し元から情報を受け取る）
  const CompletedCard({
    super.key,
    required this.challenge,
    required this.onChallengePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 241, 250, 242),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline, // お好きなアイコンに変更してください
                  color: Colors.green,
                  size: 15, // アイコンのサイズ
                ),
                Icon(
                  Icons.emoji_events_outlined, // お好きなアイコンに変更してください
                  color: Colors.green,
                  size: 15, // アイコンのサイズ
                ),
                Text(
                  '${challenge.difficulty.points}ポイント',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green, 
                  ),
                ),
            ],
          ),
            const SizedBox(width: 16),
            Text(
              challenge.title, // ← 受け取ったタイトル
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 2行目: 自分と逆の意見を示すタグ
            Row(
              children: [
                const Text('あなた: ', style: TextStyle(fontSize: 14)),

                // originalStance が存在する場合はそれを使用、なければstanceの逆を表示
                buildStanceTag(
                  (challenge.originalStance ?? (challenge.stance == Stance.pro ? Stance.con : Stance.pro)) == Stance.pro ? '賛成' : '反対',
                  (challenge.originalStance ?? (challenge.stance == Stance.pro ? Stance.con : Stance.pro)) == Stance.pro
                      ? const Color.fromARGB(255, 214, 241, 215)
                      : const Color.fromARGB(255, 249, 209, 213),
                  (challenge.originalStance ?? (challenge.stance == Stance.pro ? Stance.con : Stance.pro)) == Stance.pro
                      ? Colors.green[900]!
                      : Colors.red[900]!,
                ),

                // 矢印アイコン
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),

                const Text('挑戦: ', style: TextStyle(fontSize: 14)),

                // stance（チャレンジで取るべき立場）を表示
                buildStanceTag(
                  challenge.stance == Stance.pro ? '賛成' : '反対',
                  challenge.stance == Stance.pro
                      ? const Color.fromARGB(255, 214, 241, 215)
                      : const Color.fromARGB(255, 249, 209, 213),
                  challenge.stance == Stance.pro
                      ? Colors.green[900]!
                      : Colors.red[900]!,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity, // 横幅いっぱいに広げる
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white, // 白い背景
                borderRadius: BorderRadius.circular(8.0), // 少し角丸
                border: Border.all(color: Colors.grey[300]!), // 薄い枠線
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'あなたのチャレンジ回答:', // タイトル
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // challenge.oppositeOpinionText を表示 (nullならフォールバック)
                    challenge.oppositeOpinionText ?? '（意見が保存されていません）',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[850],
                      height: 1.5, // 行間
                    ),
                  ),
                ],
              ),
            ),

            // フィードバック表示セクション
            if (challenge.feedbackText != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.smart_toy_outlined,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AIフィードバック',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        if (challenge.feedbackScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(challenge.feedbackScore!).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'スコア: ${challenge.feedbackScore}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(challenge.feedbackScore!),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge.feedbackText!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) {
      return AppColors.agree;
    } else if (score >= 60) {
      return AppColors.difficultyNormal;
    } else if (score >= 40) {
      return AppColors.difficultyHard;
    } else {
      return AppColors.disagree;
    }
  }
}
