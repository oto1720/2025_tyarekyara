import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/daily_topic_provider.dart';
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

    // メインコンテンツ
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

  Widget _buildMainContent(DailyTopicState state) {
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
                onPressed: _isValid ? _submitOpinion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
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

  void _submitOpinion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投稿確認'),
        content: Text('立場: $_selectedStance\n\n意見を投稿しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('意見を投稿しました')),
              );
              // TODO: 実際の投稿処理を実装
            },
            child: const Text('投稿する'),
          ),
        ],
      ),
    );
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
