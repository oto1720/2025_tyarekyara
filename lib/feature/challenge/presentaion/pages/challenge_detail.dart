import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Column(
              children: [
                Card(
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: AppColors.border),
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
                            Icons.shuffle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '視点交換チャレンジ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                        widget.challenge.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events_outlined,
                            color: AppColors.difficultyNormal,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${widget.challenge.difficulty.points}ポイント',
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                elevation: 0,
                color: AppColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: AppColors.border),
                ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'あなたの元の意見 (${(widget.challenge.originalStance ?? widget.challenge.stance) == Stance.pro ? "賛成" : "反対"})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.challenge.originalOpinionText,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.5,
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(color: AppColors.border, width: 1.0),
                  ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 挑戦する側の立場を表示
                          Row(
                            children: [
                              const Icon(
                                Icons.psychology_alt_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'チャレンジ:${widget.challenge.stance == Stance.pro ? "賛成" : "反対"}の立場で考えてみよう',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.challenge.stance == Stance.pro ? "賛成" : "反対"}の立場から、説得力のある意見を書いてみてください',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '挑戦する立場:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              buildStanceTag(
                                widget.challenge.stance == Stance.pro ? '賛成' : '反対',
                                widget.challenge.stance == Stance.pro
                                    ? AppColors.agree.withValues(alpha: 0.2)
                                    : AppColors.disagree.withValues(alpha: 0.2),
                                widget.challenge.stance == Stance.pro
                                    ? AppColors.agree
                                    : AppColors.disagree,
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
                              fillColor: AppColors.surface,
                              hintText: '${widget.challenge.stance == Stance.pro ? "賛成" : "反対"}の立場での意見を書いてみよう！',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(color: AppColors.border),
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
                                    side: const BorderSide(color: AppColors.border),
                                  ),
                                  onPressed: () {
                                    debugPrint('キャンセルボタンが押されました');
                                    GoRouter.of(context).pop(null);
                                  },
                                  child: const Text(
                                    'キャンセル',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.textOnPrimary,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      // ゲストモードをチェック
                                      final prefs = await SharedPreferences.getInstance();
                                      final isGuest = prefs.getBool('is_guest_mode') ?? false;

                                      if (!mounted) return;

                                      if (isGuest) {
                                        // ゲストモードの場合、AI審査が利用できないことを通知
                                        final router = GoRouter.of(context);
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.lock_outline,
                                                  color: AppColors.warning,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text('AI審査について'),
                                              ],
                                            ),
                                            content: const Text(
                                              'AIによる審査機能は\nログインユーザーのみ利用可能です。\n\nアカウントを作成すると、\nAIからのフィードバックを受け取ることができます。',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(dialogContext).pop(),
                                                child: const Text('キャンセル'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(dialogContext).pop();
                                                  router.push('/login');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.primary,
                                                ),
                                                child: const Text('ログイン / 新規登録'),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }

                                      // 通常モード：フィードバック画面に遷移
                                      final router = GoRouter.of(context);
                                      final result = await router.push(
                                        '/challenge/${widget.challenge.id}/feedback',
                                        extra: {
                                          'challenge': widget.challenge,
                                          'challengeAnswer': _opinionController.text,
                                        },
                                      );
                                      // フィードバック画面から戻ってきたら結果を返す
                                      if (result != null && mounted) {
                                        router.pop(result);
                                      }
                                    }
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                      ),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'チャレンジ完了',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                elevation: 0,
                color: AppColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.border, width: 1.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: const Icon(
                            Icons.lightbulb_outline_sharp,
                            color: AppColors.difficultyNormal,
                            size: 20,
                          ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(width: 2),
                        ),
                        TextSpan(
                          text: 'ヒント : 相手の立場に立つことで、その意見が生まれる背景や価値観を理解できます。完全に同意する必要はありませんが、なぜそう考える人がいるのかを想像してみましょう。',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// スタンスタグを構築するメソッド
  Widget buildStanceTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
