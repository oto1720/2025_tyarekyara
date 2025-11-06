import 'package:flutter/material.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/challenge_card.dart';

class ChallengeDetailPage extends StatefulWidget {
  // どのチャレンジかを受け取るためのID
  final Challenge challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {

  // ↓↓↓ 4. フォームの状態を管理するキーを追加
  final _formKey = GlobalKey<FormState>();
  // ↓↓↓ 5. テキストフィールドの入力を管理するコントローラーを追加
  final _opinionController = TextEditingController();

  @override
    void dispose() {
      // 6. コントローラーを破棄
      _opinionController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('チャレンジ詳細 (ID: ${widget.challenge.id})')),
      body: SingleChildScrollView(
        child: Padding(
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
                              difficulty: widget.challenge.difficulty,
                              showPoints: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), // タイトルと説明文の間の小さな隙間
                      Text(
                        '${widget.challenge.title}',
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
                            '${widget.challenge.difficulty.points}ポイント',
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
        
              const SizedBox(height: 8),
              //元の意見表示のカード
              Card(
                elevation: 0, // 影をなくす
                  color: Colors.grey[100], // 背景色を少し変える
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.grey[300]!), // 薄い枠線
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'あなたの元の意見 (${widget.challenge.stance == Stance.pro ? "賛成" : "反対"})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.challenge.originalOpinionText, // 仮のデータから本文を表示
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.5, // 行間
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
              
              //テキスト入力フォームのカード
              Form(
                key: _formKey,
                child: Card(
                    elevation: 2.0, // 少し影をつける
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.purpleAccent[100]!,width: 1.0), // 薄い枠線
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 挑戦する側の立場を表示
                          Row(
                            children: [
                              Icon(
                                Icons.psychology_alt_outlined, // お好きなアイコンに変更してください
                                color: Colors.purpleAccent[700],
                                size: 20, // アイコンのサイズ
                              ),
                              Text(
                                'チャレンジ:反対の立場で考えてみよう',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // テーマの色
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                                '反対の立場から、説得力のある意見を書いてみてください',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600], // テーマの色
                                ),
                              ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                '挑戦する立場:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 7. _buildStanceTag を呼び出す
                              buildStanceTag(
                                widget.challenge.stance == Stance.pro ? '反対' : '賛成',
                                widget.challenge.stance == Stance.pro
                                    ? const Color.fromARGB(255, 249, 209, 213)
                                    : const Color.fromARGB(255, 214, 241, 215),
                                widget.challenge.stance == Stance.pro
                                    ? Colors.red[900]!
                                    : Colors.green[900]!,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 意見を記述するテキストフィールド
                          TextFormField(
                            controller: _opinionController,
                            maxLines: 8, // 少し高さを増やす
                            maxLength: 300,
                            
                            //これを表示させるとvalidatorの表示と被ってしまってvalidatorの処理が表示されなくなる
                            // buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) {
                            //   return Container(
                            //     padding: const EdgeInsets.only(top: 10), // 少し上に余白
                            //     alignment: Alignment.centerLeft,
                            //     child: Text(
                            //       '$currentLength / $maxLength (100文字以上入力してください)',
                            //       style: TextStyle(
                            //         fontSize: 12,
                            //         color: Colors.grey[600],
                            //       ),
                            //     ),
                            //   );
                            // },

                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              
                              hintText: '${widget.challenge.stance == Stance.pro ? "反対" : "賛成"}の立場での意見を書いてみよう！',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder( // 通常時の枠線
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            // ↓↓↓ 13. バリデーター（100文字チェック）を追加
                            validator: (value) {
  
                              if (value == null || value.isEmpty) {
                                return '意見を記述してください';
                              }
                              if (value.length < 100) {
                                return '100文字以上で記述してください (現在 ${value.length} 文字)';
                              }
                              return null; // 問題なし
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [

                              // キャンセルボタン
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey[400]!), // 枠線の色
                                  ),
                                  onPressed: () {
                                    // キャンセルボタンが押された時の処理
                                    print('キャンセルボタンが押されました');
                                    GoRouter.of(context).pop(null); // 前の画面に戻る
                                  },
                                  child: const Text(
                                    'キャンセル',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12), // ボタン同士の間隔
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple[300],
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50), // 横幅いっぱい、高さ50
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    
                                    // TODO: 意見を送信する処理
                                    if (_formKey.currentState!.validate()) {
                                      
                                      // バリデーションが通ったら（trueが返されたら）
                                      // TODO: 意見を送信する処理
                                      // (例: _opinionController.text を使ってデータを送信)
                                        
                                      //送信するデータをMapにまとめる
                                      final result = {
                                        'points': widget.challenge.difficulty.points,
                                        'opinion': _opinionController.text, // 入力された意見
                                      };
                                        
                                      //Mapをpopで返す
                                      GoRouter.of(context).pop(result);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(  
                                        Icons.check_circle_outline,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'チャレンジ完了',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
              //ヒントカード
              Card(
                elevation: 2.0,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.lightBlue[100]!,width: 1.0), // 薄い枠線
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(padding: const EdgeInsets.all(16.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle, // アイコンを中央揃え
                          child: Icon(
                            Icons.lightbulb_outline_sharp,
                            color: Colors.amber[700],
                            size: 20,
                          ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(width: 2), // アイコンとテキストの間隔
                        ),
                        TextSpan(
                          text: 'ヒント : 相手の立場に立つことで、その意見が生まれる背景や価値観を理解できます。完全に同意する必要はありませんが、なぜそう考える人がいるのかを想像してみましょう。',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],

                    ),
                ))
              )
            ],
          ),
        ),
      ),
    );
  }
}
