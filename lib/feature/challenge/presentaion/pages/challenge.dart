import 'package:flutter/material.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:tyarekyara/widgets/custom_button.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/challenge_card.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';

class ChallengePage extends StatelessWidget {
  const ChallengePage({super.key});

  static final Challenge challenge1 = Challenge(
    id: 'shukyu-3',
    title: '週休3日制は導入すべきか？',
    difficulty: ChallengeDifficulty.easy,
    stance: Stance.pro,
  );

  static final Challenge challenge2 = Challenge(
    id: '2',
    difficulty: ChallengeDifficulty.normal,
    title: '今日のご飯なに？',
    stance: Stance.pro,
  );

  static final Challenge challenge3 = Challenge(
    id: '3',
    difficulty: ChallengeDifficulty.hard,
    title: 'は？',
    stance: Stance.pro,
  );

  @override
  Widget build(BuildContext context) {
    double currentProgress = 0.7; // ゲージ用の割合 (0.0～1.0)
    int currentPoints = 70; // 分子 (現在のポイント)
    int maxPoints = 100; // 分母 (最大ポイント)

    return Scaffold(
      appBar: AppBar(title: const Text('新機能')),
      body: SingleChildScrollView(
        child: Padding(
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
                            Icons.emoji_events_outlined,
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
                        backgroundColor: const Color.fromARGB(
                          255,
                          184,
                          183,
                          183,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 19, 20, 20),
                        ),
                        borderRadius: BorderRadius.circular(6), // ゲージの角の丸み
                      ),
                      const SizedBox(height: 8), // 少し間隔をあける
                      // ポイントの具体的な数値表示
                      Text(
                        '次のバッジまであと${(maxPoints - currentPoints).toInt()}ポイント',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20), // カードと他のコンテンツの間隔
              // 他のコンテンツ（例: チャレンジ一覧など）
              const Center(child: Text('ここにチャレンジ一覧などを表示')),
              const SizedBox(height: 20),

              ChallengeCard(
                challenge: challenge1,
                onChallengePressed: () {
                  // TODO: 挑戦処理 1
                  GoRouter.of(
                    context,
                  ).push('/challenge/${challenge1.id}', extra: challenge1);
                  print('チャレンジ 1 が押されました');
                },
              ),

              ChallengeCard(
                challenge: challenge2,
                onChallengePressed: () {
                  GoRouter.of(
                    context,
                  ).push('/challenge/${challenge2.id}', extra: challenge2);
                  // TODO: 挑戦処理 1
                  print('今日のごはんカレー');
                },
              ),

              ChallengeCard(
                challenge: challenge3,
                onChallengePressed: () {
                  GoRouter.of(
                    context,
                  ).push('/challenge/${challenge3.id}', extra: challenge3);
                  // TODO: 挑戦処理 1
                  print('hahahhaha');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
