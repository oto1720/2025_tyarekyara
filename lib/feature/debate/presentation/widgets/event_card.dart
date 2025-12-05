import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/debate_event.dart';

/// イベントカードWidget
class EventCard extends StatelessWidget {
  final DebateEvent event;
  final VoidCallback onTap;
  final bool isCompleted;
  final bool isLocked;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isCompleted = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  _buildTitle(context),
                  const SizedBox(height: 8),
                  _buildTopic(context),
                  const SizedBox(height: 12),
                  _buildDateTime(context),
                  const SizedBox(height: 12),
                  _buildInfo(context),
                  if (!isCompleted) ...[
                    const SizedBox(height: 12),
                    _buildParticipants(context),
                  ],
                ],
              ),
            ),
          ),
          // ロック時のオーバーレイ
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ヘッダー（ステータスバッジ）
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildStatusBadge(context),
        if (isLocked) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.lock,
            color: Colors.grey[600],
            size: 20,
          ),
        ],
        const Spacer(),
        if (event.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              event.imageUrl!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.event, color: Colors.grey),
                );
              },
            ),
          ),
      ],
    );
  }

  /// ステータスバッジ
  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String statusText;

    switch (event.status) {
      case EventStatus.scheduled:
        badgeColor = Colors.blue;
        statusText = 'スケジュール済み';
        break;
      case EventStatus.accepting:
        badgeColor = Colors.green;
        statusText = 'エントリー受付中';
        break;
      case EventStatus.matching:
        badgeColor = Colors.orange;
        statusText = 'マッチング中';
        break;
      case EventStatus.inProgress:
        badgeColor = Colors.red;
        statusText = '開催中';
        break;
      case EventStatus.completed:
        badgeColor = Colors.grey;
        statusText = '完了';
        break;
      case EventStatus.cancelled:
        badgeColor = Colors.grey;
        statusText = 'キャンセル';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// タイトル
  Widget _buildTitle(BuildContext context) {
    return Text(
      event.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// トピック
  Widget _buildTopic(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.topic,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.topic,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 日時情報
  Widget _buildDateTime(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP');
    final deadlineFormat = DateFormat('MM/dd HH:mm', 'ja_JP');

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              '開催: ${dateFormat.format(event.scheduledAt)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              '締切: ${deadlineFormat.format(event.entryDeadline)}',
              style: TextStyle(
                fontSize: 14,
                color: _isDeadlineNear() ? Colors.red : Colors.grey[700],
                fontWeight: _isDeadlineNear() ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 締切が近いかチェック
  bool _isDeadlineNear() {
    final now = DateTime.now();
    final difference = event.entryDeadline.difference(now);
    return difference.inHours < 1 && difference.isNegative == false;
  }

  /// イベント情報（形式・時間）
  Widget _buildInfo(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...event.availableFormats.map((format) => _buildInfoChip(
              context,
              icon: Icons.people,
              label: format.displayName,
              color: Colors.purple,
            )),
        ...event.availableDurations.map((duration) => _buildInfoChip(
              context,
              icon: Icons.timer,
              label: duration.displayName,
              color: Colors.orange,
            )),
      ],
    );
  }

  /// 情報チップ
  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 参加者情報
  Widget _buildParticipants(BuildContext context) {
    final progress = event.currentParticipants / event.maxParticipants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '参加者',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              '${event.currentParticipants} / ${event.maxParticipants}人',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 0.8 ? Colors.red : Colors.green,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
