import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/debate_event.dart';
import '../../models/debate_match.dart';
import '../../providers/debate_event_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/debate_event_unlock_provider.dart';

/// イベント詳細画面
class DebateEventDetailPage extends ConsumerStatefulWidget {
  final String eventId;

  const DebateEventDetailPage({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<DebateEventDetailPage> createState() =>
      _DebateEventDetailPageState();
}

class _DebateEventDetailPageState extends ConsumerState<DebateEventDetailPage> {
  bool _hasNavigatedToMatch = false; // マッチ詳細画面への遷移済みフラグ

  @override
  Widget build(BuildContext context) {
    // ゲストモックイベントの場合
    if (widget.eventId == 'guest_mock_event') {
      return FutureBuilder<bool>(
        future: SharedPreferences.getInstance()
            .then((prefs) => prefs.getBool('is_guest_mode') ?? false),
        builder: (context, snapshot) {
          final isGuest = snapshot.data ?? false;
          if (!isGuest) {
            return _buildNotFound(context);
          }
          return _buildGuestMockEventDetail(context);
        },
      );
    }

    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final authStateAsync = ref.watch(authStateChangesProvider);
    final unlockedAsync = ref.watch(isDebateEventUnlockedProvider(widget.eventId));

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return _buildNotFound(context);
          }

          final user = authStateAsync.value;
          final userId = user?.uid;
          debugPrint('🔐 [EventDetail] Firebase Auth User: ${user?.uid ?? "null"}');
          debugPrint('🔐 [EventDetail] final userId: $userId');

          return unlockedAsync.when(
            data: (unlocked) {
              debugPrint('🔓 [EventDetail] unlocked: $unlocked');
              debugPrint('🔓 [EventDetail] eventId: ${event.id}');
              debugPrint('🔓 [EventDetail] userId: $userId');

              if (!unlocked) {
                debugPrint('🔒 [EventDetail] ロックビューを表示');
                return _buildLockedView(context);
              }
              debugPrint('✅ [EventDetail] イベント詳細を表示');
              return _buildEventDetail(context, ref, event, userId);
            },
            loading: () {
              debugPrint('⏳ [EventDetail] unlockedAsync loading...');
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stack) {
              debugPrint('❌ [EventDetail] unlockedAsync error: $error');
              return _buildEventDetail(context, ref, event, userId);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  /// ゲスト用のモックイベント詳細を表示
  Widget _buildGuestMockEventDetail(BuildContext context) {
    final now = DateTime.now();
    final mockEvent = DebateEvent(
      id: 'guest_mock_event',
      title: 'お試しディベート',
      topic: '環境保護のために個人の利便性を犠牲にすべきか',
      description: 'ディベート機能を体験してみましょう！\n'
          'これはゲスト用のお試しディベートです。\n\n'
          '実際のディベートでは、他のユーザーとリアルタイムで議論を交わすことができます。\n'
          'AIによる審査で、あなたの議論スキルも評価されます。',
      status: EventStatus.accepting,
      scheduledAt: now,
      entryDeadline: now.add(const Duration(days: 7)),
      createdAt: now,
      updatedAt: now,
      availableDurations: [DebateDuration.short],
      availableFormats: [DebateFormat.oneVsOne],
      currentParticipants: 0,
      maxParticipants: 100,
    );

    return Scaffold(
      body: _buildEventDetail(context, ref, mockEvent, 'guest'),
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
                if (userId != null)
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
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 1,
      title: Text(
        event.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => context.push('/debate/rules'),
          tooltip: 'ルールを確認',
        ),
      ],
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
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
        Text(
          'イベント概要',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          event.description,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.topic, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ディベートテーマ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.topic,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
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
        Text(
          '選択可能な設定',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
                  backgroundColor: color.withValues(alpha: 0.1),
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
      color: progress >= 0.9 ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '参加状況',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${event.currentParticipants} / ${event.maxParticipants}人',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 0.9 ? AppColors.error : AppColors.success,
                ),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              remaining > 0 ? '残り$remaining枠' : '満員',
              style: TextStyle(
                fontSize: 14,
                color: remaining > 0 ? AppColors.success : AppColors.error,
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
    // ゲストモードの場合は特別な処理
    if (userId == 'guest') {
      return _buildGuestTryButton(context, event);
    }

    final entryAsync = ref.watch(userEntryProvider((event.id, userId)));

    return entryAsync.when(
      data: (entry) {
        debugPrint('📋 [EntrySection] eventId: ${event.id}, userId: $userId');
        debugPrint('📋 [EntrySection] entry: ${entry != null ? "存在する (status: ${entry.status})" : "null"}');
        debugPrint('📋 [EntrySection] event.status: ${event.status}');
        debugPrint('📋 [EntrySection] _canEntry: ${_canEntry(event)}');

        if (entry != null) {
          // マッチング成立チェック - マッチ詳細画面へ自動遷移
          if (entry.status == MatchStatus.matched &&
              entry.matchId != null &&
              !_hasNavigatedToMatch) {
            _hasNavigatedToMatch = true; // フラグを立てて重複遷移を防ぐ
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                debugPrint('🎯 マッチング成立！マッチ詳細画面へ遷移: ${entry.matchId}');
                context.pushReplacement('/debate/match/${entry.matchId}');
              }
            });
          }

          // マッチング成立時は遷移中メッセージを表示
          if (entry.status == MatchStatus.matched && entry.matchId != null) {
            return Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'マッチング成立！',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'マッチ詳細画面へ遷移中...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildAlreadyEntered(context, event, entry);
        }
        // 未エントリーの場合は、エントリー可能かチェック
        if (_canEntry(event)) {
          return _buildEntryButton(context, event);
        }
        return const SizedBox.shrink();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  /// ゲスト用の「試してみる」ボタン
  Widget _buildGuestTryButton(BuildContext context, DebateEvent event) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          // 直接ディベートルームへ遷移
          context.push('/debate/room/guest_mock_match');
        },
        icon: const Icon(Icons.play_arrow, size: 28),
        label: const Text(
          '試してみる',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// エントリー済み表示
  Widget _buildAlreadyEntered(BuildContext context, DebateEvent event, entry) {
    return Column(
      children: [
        Card(
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'エントリー済み',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'マッチング完了までお待ちください',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToWaitingRoom(context, event),
            icon: const Icon(Icons.hourglass_empty, size: 28),
            label: const Text(
              '待機画面へ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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
          backgroundColor: AppColors.primary,
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
    debugPrint('🚀 Navigating to entry page: /debate/event/${event.id}/entry');
    context.push('/debate/event/${event.id}/entry');
    debugPrint('✅ Navigation command executed');
  }

  /// 待機画面へ遷移
  void _navigateToWaitingRoom(BuildContext context, DebateEvent event) {
    debugPrint('🚀 Navigating to waiting room: /debate/event/${event.id}/waiting');
    context.push('/debate/event/${event.id}/waiting');
    debugPrint('✅ Navigation command executed');
  }

  /// 見つからない表示
  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'イベントが見つかりません',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
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
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'エラー: $error',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }

  /// ロックビュー
  Widget _buildLockedView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
          title: const Text(
            'ディベートイベント',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '今日のディベート',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '今日のトピックに回答すると\n'
                    'このディベートに参加できます',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.edit),
                    label: const Text('トピックに回答する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
