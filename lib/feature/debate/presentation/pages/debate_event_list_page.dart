import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/debate_event.dart';
import '../../models/debate_match.dart';
import '../../providers/debate_event_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../providers/today_debate_event_provider.dart';
import '../../../../core/providers/debate_event_unlock_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/event_card.dart';

/// ディベートイベント一覧画面
class DebateEventListPage extends ConsumerStatefulWidget {
  const DebateEventListPage({super.key});

  @override
  ConsumerState<DebateEventListPage> createState() =>
      _DebateEventListPageState();
}

class _DebateEventListPageState extends ConsumerState<DebateEventListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('is_guest_mode') ?? false),
      builder: (context, snapshot) {
        final isGuest = snapshot.data ?? false;

        // ゲストモードの場合、ログイン要求画面を表示
        if (isGuest) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('ディベートイベント'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'ディベート機能を利用するには\nログインが必要です',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'アカウントを作成してディベートに参加しましょう',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                      child: const Text('ログイン / 新規登録'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 通常の画面表示
        return Scaffold(
          appBar: AppBar(
            title: const Text('ディベートイベント'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => context.push('/debate/rules'),
                tooltip: 'ルールを確認',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '開催予定'),
                Tab(text: '参加履歴'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingEventsTab(),
              _buildCompletedEventsTab(),
            ],
          ),
        );
      },
    );
  }

  /// 開催予定イベントタブ
  Widget _buildUpcomingEventsTab() {
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final todayDebateUnlockedAsync = ref.watch(isTodayDebateUnlockedProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_available,
            message: '開催予定のイベントはありません',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(upcomingEventsProvider);
            ref.invalidate(isTodayDebateUnlockedProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 95), // BottomNavigationBar分の余白
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isToday = ref.watch(isTodayEventProvider(event.id));

              return todayDebateUnlockedAsync.when(
                data: (unlocked) => EventCard(
                  event: event,
                  isLocked: isToday && !unlocked,
                  onTap: () => _handleEventTap(
                    context,
                    event,
                    isToday,
                    unlocked,
                  ),
                ),
                loading: () => EventCard(
                  event: event,
                  isLocked: isToday,
                  onTap: () {},
                ),
                error: (_, __) => EventCard(
                  event: event,
                  isLocked: false,
                  onTap: () => _navigateToEventDetail(event),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  /// 参加履歴タブ
  Widget _buildCompletedEventsTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildEmptyState(
        icon: Icons.login,
        message: 'ログインしてください',
      );
    }

    final matchesAsync = ref.watch(matchHistoryProvider(user.uid));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            message: '参加履歴はありません',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 95), // BottomNavigationBar分の余白
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            // イベント情報を取得してお題を表示
            return FutureBuilder<String?>(
              future: _getEventTopic(match.eventId),
              builder: (context, snapshot) {
                final topic = snapshot.data;
                return _buildMatchHistoryCard(match, user.uid, topic);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  /// イベントのお題を取得
  Future<String?> _getEventTopic(String eventId) async {
    try {
      final repository = ref.read(debateEventRepositoryProvider);
      final event = await repository.getEvent(eventId);
      return event?.topic;
    } catch (e) {
      print('Error getting event topic: $e');
      return null;
    }
  }

  /// マッチ履歴カード
  Widget _buildMatchHistoryCard(DebateMatch match, String userId, String? topic) {
    // ユーザーがどちらのチームにいるか判定
    final isProTeam = match.proTeam.memberIds.contains(userId);
    final userTeam = isProTeam ? '賛成' : '反対';
    final teamColor = isProTeam ? Colors.blue : Colors.red;

    // ステータスに応じた表示
    String statusText;
    Color statusColor;
    bool canViewResult = false;

    switch (match.status) {
      case MatchStatus.completed:
        statusText = '完了';
        statusColor = Colors.green;
        canViewResult = true;
        break;
      case MatchStatus.inProgress:
        statusText = '進行中';
        statusColor = Colors.orange;
        break;
      case MatchStatus.matched:
        statusText = 'マッチング済み';
        statusColor = Colors.blue;
        break;
      default:
        statusText = match.status.name;
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: canViewResult
            ? () => context.push('/debate/result/${match.id}')
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー行
              Row(
                children: [
                  // チームバッジ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: teamColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: teamColor),
                    ),
                    child: Text(
                      userTeam,
                      style: TextStyle(
                        color: teamColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 形式バッジ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.format == DebateFormat.oneVsOne ? '1vs1' : '2vs2',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // ステータス
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // お題
              if (topic != null) ...[
                const SizedBox(height: 12),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              // 日時
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(match.matchedAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // 結果確認ボタン
              if (canViewResult) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.push('/debate/result/${match.id}'),
                      icon: const Icon(Icons.assessment, size: 18),
                      label: const Text('結果を見る'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 空状態の表示
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// エラー状態の表示
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'エラーが発生しました',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(upcomingEventsProvider);
              ref.invalidate(completedEventsProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('再読み込み'),
          ),
        ],
      ),
    );
  }

  /// イベントタップ時の処理
  void _handleEventTap(
    BuildContext context,
    DebateEvent event,
    bool isToday,
    bool unlocked,
  ) {
    if (isToday && !unlocked) {
      // ロック中のダイアログを表示
      _showLockedDialog(context);
      return;
    }

    // 通常の遷移
    _navigateToEventDetail(event);
  }

  /// ロックダイアログを表示
  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('ディベートイベント'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日のディベートに参加するには、\n'
              'まず今日のトピックに回答してください！',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'あなたの意見を投稿すると、\nディベートが解放されます',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/'); // ホームに移動
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('トピックに回答する'),
          ),
        ],
      ),
    );
  }

  /// イベント詳細画面へ遷移
  void _navigateToEventDetail(DebateEvent event) {
    context.push('/debate/event/${event.id}');
  }
}
