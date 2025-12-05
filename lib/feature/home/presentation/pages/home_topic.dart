import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ✅ カテゴリー付きトピックカード
class TopicCard extends StatelessWidget {
  final String category;
  final String date;
  final String title;
  final String description;

  const TopicCard({
    super.key,
    required this.category,
    required this.date,
    required this.title,
    required this.description,
  });

  /// カテゴリーに応じたテーマカラーを返す
  Color getCategoryColor() {
    switch (category) {
      case '社会問題':
        return Colors.blue;
      case '環境':
        return Colors.green;
      case '教育':
        return Colors.orange;
      case 'テクノロジー':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// カテゴリーに応じたアイコンを返す（おまけ機能✨）
  IconData getCategoryIcon() {
    switch (category) {
      case '社会問題':
        return Icons.public;
      case '環境':
        return Icons.eco;
      case '教育':
        return Icons.school;
      case 'テクノロジー':
        return Icons.memory;
      default:
        return Icons.topic;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = getCategoryColor();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.08), // 背景を薄く色づけ
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリーバッジ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(getCategoryIcon(), size: 12, color: categoryColor),
                const SizedBox(width: 4),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    color: categoryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 投稿日時
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // タイトル
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // 説明
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ メイン画面（意見投稿）
class OpinionPostScreen extends ConsumerStatefulWidget {
  const OpinionPostScreen({super.key});

  @override
  ConsumerState<OpinionPostScreen> createState() => _OpinionPostScreenState();
}

class _OpinionPostScreenState extends ConsumerState<OpinionPostScreen> {
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '意見を投稿する',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ✅ トピックカード（カテゴリーごとに色が変わる）
            const TopicCard(
              category: '社会問題',
              date: '2025年10月26日',
              title: '週休3日制は導入すべきか？',
              description:
                  '労働時間の短縮と生産性向上の観点から、週休3日制が議論されています。ワークライフバランスの改善、企業の生産性への影響など、様々な立場から考えることができます。',
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
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('意見を投稿しました')));
            },
            child: const Text('投稿する'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavBarItem(icon: Icons.home, label: 'ホーム', isActive: true),
              _NavBarItem(
                icon: Icons.emoji_events,
                label: 'チャレンジ',
                isActive: false,
              ),
              _NavBarItem(icon: Icons.subject, label: '統計', isActive: false),
              _NavBarItem(icon: Icons.person, label: 'プロフィール', isActive: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ 立場選択ボタン
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
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
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

/// ✅ 下部ナビゲーションアイテム
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? Colors.orange : Colors.grey.shade600,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.orange : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
