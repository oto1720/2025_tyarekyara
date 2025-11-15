import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/debate_event.dart';
import '../../providers/debate_event_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../../auth/providers/auth_provider.dart';

/// イベント詳細画面
class DebateEventDetailPage extends ConsumerWidget {
  final String eventId;

  const DebateEventDetailPage({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return _buildNotFound(context);
          }

          final userId = authState.maybeWhen(
            authenticated: (user) => user.id,
            orElse: () => null,
          );

          return _buildEventDetail(context, ref, event, userId);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  /// イベント詳細表示
  Widget _buildEventDetail(
    BuildContext context,
    WidgetRef ref,
    DebateEvent event,
    String? userId,
  ) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, event),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventInfo(context, event),
                const SizedBox(height: 24),
                _buildDescription(context, event),
                const SizedBox(height: 24),
                _buildAvailableOptions(context, event),
                const SizedBox(height: 24),
                _buildParticipantsInfo(context, event),
                const SizedBox(height: 24),
                if (userId != null && _canEntry(event))
                  _buildEntrySection(context, ref, event, userId),
                const SizedBox(height: 80), // ボタンの余白
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// AppBar
  Widget _buildAppBar(BuildContext context, DebateEvent event) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          event.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        background: event.imageUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    event.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultBackground();
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildDefaultBackground(),
      ),
    );
  }

  /// デフォルト背景
  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!,
            Colors.purple[400]!,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: Colors.white54,
        ),
      ),
    );
  }

  /// イベント情報
  Widget _buildEventInfo(BuildContext context, DebateEvent event) {
    final dateFormat = DateFormat('yyyy年MM月dd日 (E) HH:mm', 'ja_JP');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: '開催日時',
              value: dateFormat.format(event.scheduledAt),
              color: Colors.blue,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'エントリー締切',
              value: dateFormat.format(event.entryDeadline),
              color: Colors.orange,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.people,
              label: '参加者数',
              value: '${event.currentParticipants} / ${event.maxParticipants}人',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// 情報行
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 説明
  Widget _buildDescription(BuildContext context, DebateEvent event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'イベント概要',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          event.description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.topic, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ディベートテーマ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.topic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 選択可能なオプション
  Widget _buildAvailableOptions(BuildContext context, DebateEvent event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '選択可能な設定',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: 'ディベート形式',
          icon: Icons.people,
          color: Colors.purple,
          options: event.availableFormats
              .map((format) => format.displayName)
              .toList(),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: 'ディベート時間',
          icon: Icons.timer,
          color: Colors.orange,
          options: event.availableDurations
              .map((duration) => duration.displayName)
              .toList(),
        ),
      ],
    );
  }

  /// オプションカード
  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> options,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                return Chip(
                  label: Text(option),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 参加者情報
  Widget _buildParticipantsInfo(BuildContext context, DebateEvent event) {
    final progress = event.currentParticipants / event.maxParticipants;
    final remaining = event.maxParticipants - event.currentParticipants;

    return Card(
      color: progress >= 0.9 ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '参加状況',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${event.currentParticipants} / ${event.maxParticipants}人',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 0.9 ? Colors.red : Colors.green,
                ),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              remaining > 0 ? '残り$remaining枠' : '満員',
              style: TextStyle(
                fontSize: 14,
                color: remaining > 0 ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// エントリーセクション
  Widget _buildEntrySection(
    BuildContext context,
    WidgetRef ref,
    DebateEvent event,
    String userId,
  ) {
    final entryAsync = ref.watch(userEntryProvider((event.id, userId)));

    return entryAsync.when(
      data: (entry) {
        if (entry != null) {
          return _buildAlreadyEntered(context, entry);
        }
        return _buildEntryButton(context, event);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  /// エントリー済み表示
  Widget _buildAlreadyEntered(BuildContext context, entry) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.blue, size: 32),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'エントリー済み',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'マッチング完了までお待ちください',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
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

  /// エントリーボタン
  Widget _buildEntryButton(BuildContext context, DebateEvent event) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToEntry(context, event),
        icon: const Icon(Icons.how_to_reg, size: 28),
        label: const Text(
          'エントリーする',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// エントリー可能かチェック
  bool _canEntry(DebateEvent event) {
    return event.status == EventStatus.accepting &&
        event.currentParticipants < event.maxParticipants &&
        DateTime.now().isBefore(event.entryDeadline);
  }

  /// エントリー画面へ遷移
  void _navigateToEntry(BuildContext context, DebateEvent event) {
    context.push('/debate/event/${event.id}/entry');
  }

  /// 見つからない表示
  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'イベントが見つかりません',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }

  /// エラー表示
  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text('エラー: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}
