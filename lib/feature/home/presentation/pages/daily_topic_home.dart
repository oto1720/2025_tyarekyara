import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/opinion.dart';
import '../../providers/daily_topic_provider.dart';
import '../../providers/opinion_provider.dart';
import '../widgets/topic_card.dart';

/// 日別トピックのホーム画面
class DailyTopicHomeScreen extends ConsumerStatefulWidget {
  const DailyTopicHomeScreen({super.key});

  @override
  ConsumerState<DailyTopicHomeScreen> createState() =>
      _DailyTopicHomeScreenState();
}

class _DailyTopicHomeScreenState extends ConsumerState<DailyTopicHomeScreen> {
  final TextEditingController _opinionController = TextEditingController();
  String? _selectedStance;

  final int _minLength = 100;
  final int _maxLength = 3000;

  @override
  void dispose() {
    _opinionController.dispose();
    super.dispose();
  }

  int get _currentLength => _opinionController.text.length;
  bool get _isValid =>
      _currentLength >= _minLength &&
      _currentLength <= _maxLength &&
      _selectedStance != null;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyTopicProvider);
    final notifier = ref.read(dailyTopicProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '今日のトピック',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // リロードボタン（管理者用）
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: state.isLoading || state.isGenerating
                ? null
                : () => notifier.loadTodayTopic(),
          ),
        ],
      ),
      body: _buildBody(state, notifier),
    );
  }

  Widget _buildBody(DailyTopicState state, DailyTopicNotifier notifier) {
    // エラー表示
    if (state.error != null) {
      return _buildErrorView(state.error!, notifier);
    }

    // ローディング表示
    if (state.isLoading || state.isGenerating) {
      return _buildLoadingView(state.isGenerating);
    }

    // トピックが存在しない場合
    if (state.currentTopic == null) {
      return _buildEmptyView(notifier);
    }

    // 投稿済みチェック
    final topic = state.currentTopic!;
    final postState = ref.watch(opinionPostProvider(topic.id));

    // 投稿済みの場合は意見一覧画面に自動遷移
    if (postState.hasPosted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/opinions/${topic.id}');
      });
      return const Center(child: CircularProgressIndicator());
    }

    // 未投稿の場合は投稿フォームを表示
    return _buildMainContent(state);
  }

  Widget _buildErrorView(String error, DailyTopicNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => notifier.loadTodayTopic(),
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(bool isGenerating) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            isGenerating ? '新しいトピックを生成中...' : '読み込み中...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(DailyTopicNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'トピックがありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '新しいトピックを生成してください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => notifier.generateNewTopic(),
              icon: const Icon(Icons.add),
              label: const Text('トピックを生成'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyPostedView(topic) {
    final postState = ref.watch(opinionPostProvider(topic.id));

    return SingleChildScrollView(
      child: Column(
        children: [
          // トピックカード
          TopicCard(
            topic: topic,
            dateText: '今日のトピック',
          ),

          const SizedBox(height: 24),

          // 投稿済みメッセージ
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200, width: 1.5),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green.shade600,
                ),
                const SizedBox(height: 12),
                Text(
                  '投稿完了！',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'このトピックに既に意見を投稿しています',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (postState.userOpinion != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'あなたの立場:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              postState.userOpinion!.stance.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // みんなの意見を見るボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/opinions/${topic.id}'),
                icon: const Icon(Icons.people),
                label: const Text('みんなの意見を見る'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMainContent(DailyTopicState state) {
    final topic = state.currentTopic!;
    final postState = ref.watch(opinionPostProvider(topic.id));
    final isPosting = postState.isPosting;

    return SingleChildScrollView(
      child: Column(
        children: [
          // トピックカード
          TopicCard(
            topic: state.currentTopic!,
            dateText: '今日のトピック',
          ),

          const SizedBox(height: 16),

          // 意見入力エリア
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'あなたの意見を聞かせてください',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '投稿後に他の人の意見が閲覧可能',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                // 立場選択
                Row(
                  children: [
                    Expanded(
                      child: _StanceButton(
                        label: '賛成',
                        icon: Icons.thumb_up_outlined,
                        isSelected: _selectedStance == '賛成',
                        color: Colors.blue,
                        onTap: () => setState(() => _selectedStance = '賛成'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StanceButton(
                        label: '反対',
                        icon: Icons.thumb_down_outlined,
                        isSelected: _selectedStance == '反対',
                        color: Colors.red,
                        onTap: () => setState(() => _selectedStance = '反対'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StanceButton(
                        label: '中立・どちらとも言えない',
                        icon: Icons.horizontal_rule,
                        isSelected: _selectedStance == '中立',
                        color: Colors.grey,
                        onTap: () => setState(() => _selectedStance = '中立'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  'その理由を教えてください（100〜3000文字）',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _opinionController,
                  maxLines: 8,
                  maxLength: _maxLength,
                  decoration: InputDecoration(
                    hintText: 'あなたの考えを具体的に書いてください',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),

                // 文字数カウンター
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentLength < _minLength
                          ? 'あと${_minLength - _currentLength}文字'
                          : '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    Text(
                      '$_currentLength / $_maxLength文字',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 投稿ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isValid && !isPosting) ? _submitOpinion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isPosting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        '意見を投稿する',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isValid ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _submitOpinion() async {
    final topicState = ref.read(dailyTopicProvider);
    final topic = topicState.currentTopic;
    if (topic == null) return;

    // 立場をOpinionStanceに変換
    OpinionStance stance;
    switch (_selectedStance) {
      case '賛成':
        stance = OpinionStance.agree;
        break;
      case '反対':
        stance = OpinionStance.disagree;
        break;
      case '中立':
        stance = OpinionStance.neutral;
        break;
      default:
        return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投稿確認'),
        content: Text('立場: $_selectedStance\n\n意見を投稿しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('投稿する'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 投稿処理
    final postNotifier = ref.read(opinionPostProvider(topic.id).notifier);
    final success = await postNotifier.postOpinion(
      topicText: topic.text,
      topicDifficulty: topic.difficulty, // トピックの難易度を渡す
      stance: stance,
      content: _opinionController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('意見を投稿しました！')),
      );
      // 投稿成功後、画面が自動的に投稿完了画面に切り替わる
      // （hasPostedがtrueになるため）
    } else {
      final error = ref.read(opinionPostProvider(topic.id)).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? '投稿に失敗しました')),
      );
    }
  }
}

/// 立場選択ボタン
class _StanceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StanceButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
