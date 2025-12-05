import 'package:flutter/material.dart';
import '../../models/debate_event.dart';
import '../../models/debate_match.dart';

/// エントリー設定フォームWidget
class EntryForm extends StatefulWidget {
  final DebateEvent event;
  final Function({
    required DebateDuration duration,
    required DebateFormat format,
    required DebateStance stance,
  }) onSubmit;

  const EntryForm({
    super.key,
    required this.event,
    required this.onSubmit,
  });

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  DebateDuration? _selectedDuration;
  DebateFormat? _selectedFormat;
  DebateStance _selectedStance = DebateStance.any;

  @override
  void initState() {
    super.initState();
    // デフォルト値を設定
    if (widget.event.availableDurations.isNotEmpty) {
      _selectedDuration = widget.event.availableDurations.first;
    }
    if (widget.event.availableFormats.isNotEmpty) {
      _selectedFormat = widget.event.availableFormats.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDurationSelection(),
        const SizedBox(height: 24),
        _buildFormatSelection(),
        const SizedBox(height: 24),
        _buildStanceSelection(),
        const SizedBox(height: 32),
        _buildSubmitButton(),
      ],
    );
  }

  /// ディベート時間選択
  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.timer, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'ディベート時間',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.event.availableDurations.map((duration) {
            final isSelected = _selectedDuration == duration;
            return _buildOptionChip(
              label: duration.displayName,
              isSelected: isSelected,
              color: Colors.orange,
              onTap: () {
                setState(() {
                  _selectedDuration = duration;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _getDurationDescription(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// ディベート形式選択
  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.people, color: Colors.purple),
            SizedBox(width: 8),
            Text(
              'ディベート形式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.event.availableFormats.map((format) {
            final isSelected = _selectedFormat == format;
            return _buildOptionChip(
              label: format.displayName,
              isSelected: isSelected,
              color: Colors.purple,
              onTap: () {
                setState(() {
                  _selectedFormat = format;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _getFormatDescription(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 立場選択
  Widget _buildStanceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.psychology, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              '希望する立場',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: RadioGroup<DebateStance>(
              groupValue: _selectedStance,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStance = value;
                  });
                }
              },
              child: Column(
                children: [
                  _buildStanceOption(
                    stance: DebateStance.pro,
                    icon: Icons.thumb_up,
                    title: '賛成',
                    description: '「${widget.event.topic}」に賛成の立場で議論',
                  ),
                  const Divider(height: 16),
                  _buildStanceOption(
                    stance: DebateStance.con,
                    icon: Icons.thumb_down,
                    title: '反対',
                    description: '「${widget.event.topic}」に反対の立場で議論',
                  ),
                  const Divider(height: 16),
                  _buildStanceOption(
                    stance: DebateStance.any,
                    icon: Icons.shuffle,
                    title: 'どちらでも可',
                    description: 'マッチング時に自動で振り分け（推奨）',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '「どちらでも可」を選択すると、マッチングが成立しやすくなります',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 立場オプション
  Widget _buildStanceOption({
    required DebateStance stance,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedStance == stance;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStance = stance;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Radio<DebateStance>(
              value: stance,
            ),
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// オプションチップ
  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// 送信ボタン
  Widget _buildSubmitButton() {
    final canSubmit = _selectedDuration != null && _selectedFormat != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: canSubmit
            ? () {
                widget.onSubmit(
                  duration: _selectedDuration!,
                  format: _selectedFormat!,
                  stance: _selectedStance,
                );
              }
            : null,
        icon: const Icon(Icons.check_circle, size: 28),
        label: const Text(
          'エントリーを確定',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
      ),
    );
  }

  /// 時間の説明文
  String _getDurationDescription() {
    if (_selectedDuration == null) return '';

    switch (_selectedDuration!) {
      case DebateDuration.short:
        return '短時間でテンポよく議論（初心者向け）';
      case DebateDuration.medium:
        return 'バランスの取れた議論（推奨）';
      case DebateDuration.long:
        return 'じっくり深く議論（経験者向け）';
    }
  }

  /// 形式の説明文
  String _getFormatDescription() {
    if (_selectedFormat == null) return '';

    switch (_selectedFormat!) {
      case DebateFormat.oneVsOne:
        return '1対1で集中的に議論';
      case DebateFormat.twoVsTwo:
        return '2対2でチーム戦略を楽しむ';
    }
  }
}
