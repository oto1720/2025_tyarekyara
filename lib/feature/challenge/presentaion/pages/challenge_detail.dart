import 'package:flutter/material.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:tyarekyara/core/route/app_router.dart';

class ChallengeDetailPage extends StatelessWidget {
  // どのチャレンジかを受け取るためのID
  final Challenge challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    // ここで challengeId を使って、タイトルなどを表示する
    // (今は仮でIDをそのまま表示します)
    double currentProgress = 0.7; // ゲージ用の割合 (0.0～1.0)
    int currentPoints = 70; // 分子 (現在のポイント)
    int maxPoints = 100; // 分母 (最大ポイント)

    return Scaffold(
      appBar: AppBar(title: Text('チャレンジ詳細 (ID: ${challenge.id})')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: const Color.fromARGB(255, 239, 212, 244),
              elevation: 4.0, // 影の濃さ
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // カードの角の丸み
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // カード内部の余白
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                  children: [
                    // 説明テキスト
                    Row(
                      children: [
                        // 1. アイコンを表示
                        Icon(
                          Icons.shuffle, // お好きなアイコンに変更してください
                          color: Colors.purpleAccent[700],
                          size: 20, // アイコンのサイズ
                        ),
                        const SizedBox(width: 8), // アイコンとテキストの間隔
                        // 2. 説明テキスト
                        Text(
                          '視点交換チャレンジ', // もっと長い説明
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: DifficultyBadge(
                            difficulty: challenge.difficulty,
                            showPoints: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4), // タイトルと説明文の間の小さな隙間
                    Text(
                      '${challenge.title}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // 少し薄い色に
                      ),
                    ),
                    const SizedBox(height: 8), // 少し間隔をあける
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined, // お好きなアイコンに変更してください
                          color: Colors.amber,
                          size: 20, // アイコンのサイズ
                        ),
                        Text(
                          '${challenge.difficulty.points}ポイント',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87, // 少し薄い色に
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Text(
              'ID: ${challenge.id} のチャレンジに取り組んでいます。',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // 意見を記述するテキストフィールド
            TextField(
              maxLines: 5, // 5行分の高さ
              decoration: InputDecoration(
                hintText: 'あなたの意見を記述してください...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: 意見を送信する処理
                // 送信したら前の画面に戻る
                Navigator.of(context).pop();
              },
              child: const Text('意見を送信する'),
            ),
          ],
        ),
      ),
    );
  }
}
