import 'package:flutter/material.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:tyarekyara/widgets/custom_button.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/challenge_card.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/challenge/providers/challenge_provider.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/CompletedChallenge_card.dart';

class ChallengePage extends ConsumerStatefulWidget {
  const ChallengePage({super.key});

// //仮のチャレンジカードデータ
//   static final Challenge challenge1 = Challenge(
//     id: 'shukyu-3',
//     title: '週休3日制は導入すべきか？',
//     difficulty: ChallengeDifficulty.easy,
//     stance: Stance.pro,
//     originalOpinionText: '週休3日制は、労働者のワークライフバランスを向上させ、生産性を高める可能性があります。'
//   );

//   static final Challenge challenge2 = Challenge(
//     id: '2',
//     difficulty: ChallengeDifficulty.normal,
//     title: '今日のご飯なに？',
//     stance: Stance.pro,
//     originalOpinionText: 'カレーライスが食べたいです。',
//   );

//   static final Challenge challenge3 = Challenge(
//     id: '3',
//     difficulty: ChallengeDifficulty.hard,
//     title: 'は？',
//     stance: Stance.pro,
//     originalOpinionText: 'は？'
//   );

//   static final List<Challenge> allChallenges = [
//     challenge1,
//     challenge2,
//     challenge3,
//   ];

  @override
  ConsumerState<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends ConsumerState<ChallengePage> {

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(challengeProvider);
    final currentPoints = challengeState.currentPoints; // Providerから取得
    final maxPoints = challengeState.maxPoints; // Providerから取得
    // currentProgressを計算で求める
    double currentProgress = maxPoints > 0 ? currentPoints / maxPoints : 0.0;
    // 1.0を超えないようにする
    if (currentProgress > 1.0) currentProgress = 1.0;

    //Providerからフィルタリング済みのリストを取得
    final List<Challenge> challenges = challengeState.filteredChallenges;


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

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // 1つ目のボタン (インデックス 0)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // 7. 【変更】Providerの状態で色を決定
                              backgroundColor: challengeState.currentFilter == ChallengeFilter.available 
                                ? Colors.black 
                                : Colors.white,
                              foregroundColor: challengeState.currentFilter == ChallengeFilter.available 
                                ? Colors.white 
                                : Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // 8. 【変更】Providerのメソッドを呼び出す (setStateは不要)
                              // readを呼び出す（状態の変更だけなので）
                              ref.read(challengeProvider.notifier).setFilter(ChallengeFilter.available);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon( Icons.bolt,),
                                const SizedBox(width: 8),
                                Text(
                                  '挑戦可能',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          ),
                        ),
                      ),

                      // 2つ目のボタン (インデックス 1)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // 9. 【変更】Providerの状態で色を決定
                              backgroundColor: challengeState.currentFilter == ChallengeFilter.completed 
                                ? Colors.black 
                                : Colors.white,
                              foregroundColor: challengeState.currentFilter == ChallengeFilter.completed 
                                ? Colors.white 
                                : Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // 10. 【変更】Providerのメソッドを呼び出す
                              ref.read(challengeProvider.notifier).setFilter(ChallengeFilter.completed);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon( Icons.check_circle_outline,),
                                const SizedBox(width: 8),
                                Text(
                                  '完了済み',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              

              //仮のチャレンジカードの表示
              ...challenges.map((challenge) {
                //フィルタ状態を取得
                final bool isAvailable = challengeState.currentFilter == ChallengeFilter.available;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: isAvailable
                      ? ChallengeCard(
                          challenge: challenge,
                          onChallengePressed: () async {
                            final result = await context.push<Map<String, dynamic>>(
                                    '/challenge/${challenge.id}',
                                    extra: challenge,
                                );

                                if (result != null && mounted) {
                                  final int earnedPoints = result['points'];
                                  final String opinionText = result['opinion'];

                                  // 10. [修正] Providerのメソッドを呼び出して状態を更新
                                  ref.read(challengeProvider.notifier).completeChallenge(
                                      challenge.id,
                                      opinionText, // 提出された意見
                                      earnedPoints, // 獲得ポイント
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('チャレンジ完了！ +$earnedPoints ポイント獲得しました！'),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                          }
                        )
                  : CompletedCard( // 完了済みの場合
                      challenge: challenge,
                      // TODO: 完了済みカードをタップした時の動作（詳細確認など）
                      // onTap: () { ... }
                      onChallengePressed: () async{
                        // 完了済みカードをタップした時の動作（詳細確認など）
                        print('完了済みカードがタップされました: ${challenge.title}');
                      },
                    ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
