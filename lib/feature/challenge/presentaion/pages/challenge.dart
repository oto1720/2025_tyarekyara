import 'package:flutter/material.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:tyarekyara/widgets/custom_button.dart';

class ChallengePage extends StatelessWidget {
  const ChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    double currentProgress = 0.7; // ゲージ用の割合 (0.0～1.0)
    int currentPoints = 70; // 分子 (現在のポイント)
    int maxPoints = 100; // 分母 (最大ポイント)

    return Scaffold(
      appBar: AppBar(title: const Text('新機能')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 画面全体に余白
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 子を横幅いっぱいに広げる
          children: [
            // --- ここからがポイントゲージの部分 ---
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
                      ],
                    ),
                    const SizedBox(height: 4), // タイトルと説明文の間の小さな隙間
                    Text(
                      '自分と反対の立場で考えることで、多角的な思考力を鍛えましょう',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600], // 少し薄い色に
                      ),
                    ),
                    const SizedBox(height: 8), // 少し間隔をあける

                    Row(
                      children: [
                        // 左側のテキスト
                        Text(
                          '累計獲得ポイント',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        // 間のスペースを最大まで広げる
                        const Spacer(),
                        Icon(
                          Icons.emoji_events,
                          color: Colors.amber[700],
                          size: 20,
                        ),
                        // 右側のテキスト（分数）
                        Text(
                          '$currentPoints / $maxPoints P',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[800], // 少し濃い色に
                          ),
                        ),
                      ],
                    ),

                    // ポイントゲージ（例として LinearProgressIndicator を使用）
                    LinearProgressIndicator(
                      value: currentProgress, // ポイントの割合（0.0～1.0）
                      minHeight: 12, // ゲージの太さ
                      backgroundColor: const Color.fromARGB(255, 184, 183, 183),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 19, 20, 20),
                      ),
                      borderRadius: BorderRadius.circular(6), // ゲージの角の丸み
                    ),
                    const SizedBox(height: 8), // 少し間隔をあける
                    // ポイントの具体的な数値表示
                    Text(
                      '${(currentProgress * 100).toInt()}% 達成',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20), // カードと他のコンテンツの間隔
            // 他のコンテンツ（例: チャレンジ一覧など）
            const Center(child: Text('ここにチャレンジ一覧などを表示')),

            Card(
              elevation: 2.0, // ポイントゲージより少し影を薄くする（お好みで）
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      '週休3日制は導入すべきか？',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // --- ここにチャレンジ1つ分のレイアウトを作る ---
                    // 例:
                    Row(
                      children: [
                        // 左側にチャレンジのアイコン
                        Icon(Icons.lightbulb_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        // 中央にチャレンジ名と説明
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'チャレンジ 1: 他人の靴を履く（想像）',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'あの人がなぜそうしたのか考えてみよう',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        // 右側に「挑戦」ボタン
                        ElevatedButton(
                          onPressed: () {
                            // TODO: チャレンジ挑戦処理
                          },
                          child: const Text('挑戦'),
                        ),
                      ],
                    ),

                    // TODO: 後でここを ListView などに変更する
                    // --- チャレンジ1つ分のレイアウトここまで ---
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
