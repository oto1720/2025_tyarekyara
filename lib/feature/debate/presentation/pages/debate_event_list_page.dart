import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../models/debate_event.dart';
import '../../models/debate_match.dart';
import '../../providers/debate_event_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../providers/today_debate_event_provider.dart';
import '../../../../core/providers/debate_event_unlock_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/event_card.dart';
import '../../../guide/presentaion/widgets/tutorial_showcase_wrapper.dart';
import '../../../guide/presentaion/widgets/tutorial_dialog.dart' show TutorialBottomSheet;

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
  final GlobalKey _helpButtonKey = GlobalKey();

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
    return ShowCaseWidget(
      builder: (context) => TutorialShowcaseWrapper(
        pageKey: 'debate',
        showcaseKey: _helpButtonKey,
        child: FutureBuilder<bool>(
          future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('is_guest_mode') ?? false),
          builder: (context, snapshot) {
        final isGuest = snapshot.data ?? false;

        // 通常の画面表示（ゲストモードでも表示）
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ディベートイベント'),
                if (isGuest)
                  const Text(
                    'ユーザーとのディベートはログインが必要です',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
            actions: [
              Showcase(
                key: _helpButtonKey,
                title: '操作ガイド',
                description: '詳細はここにあります。確認しましょう',
                child: IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    TutorialBottomSheet.show(context, 'debate');
                  },
                  tooltip: '操作ガイド',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => context.push('/debate/rules'),
                tooltip: 'ルールを確認',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // 現在のタブに応じてリロード
                  if (_tabController.index == 0) {
                    // 開催予定タブ
                    ref.invalidate(upcomingEventsProvider);
                    ref.invalidate(isTodayDebateUnlockedProvider);
                  } else {
                    // 参加履歴タブ
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      ref.invalidate(matchHistoryProvider(user.uid));
                    }
                  }
                },
                tooltip: 'リロード',
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
              _buildUpcomingEventsTab(isGuest),
              _buildCompletedEventsTab(isGuest),
            ],
          ),
        );
      },
        ),
      ),
    );
  }

  /// 開催予定イベントタブ
  Widget _buildUpcomingEventsTab(bool isGuest) {
    // ゲストモードの場合はモックイベントを表示
    if (isGuest) {
      return _buildGuestMockEvents();
    }

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

  /// ゲスト用のモックイベントを表示
  Widget _buildGuestMockEvents() {
    final now = DateTime.now();
    final mockEvent = DebateEvent(
      id: 'guest_mock_event',
      title: 'お試しディベート',
      topic: '環境保護のために個人の利便性を犠牲にすべきか',
      description: 'ディベート機能を体験してみましょう！\nこれはゲスト用のお試しディベートです。',
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 95),
      children: [
        // ゲストモード説明バナー
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue[300]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'お試しモード',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ディベート機能を体験できます。\n本格的なユーザー対戦を楽しむにはログインしてください。',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ログイン / 新規登録'),
                ),
              ),
            ],
          ),
        ),
        // モックイベントカード
        EventCard(
          event: mockEvent,
          isLocked: false,
          onTap: () => context.push('/debate/event/guest_mock_event'),
        ),
      ],
    );
  }

  /// 参加履歴タブ
  Widget _buildCompletedEventsTab(bool isGuest) {
    // ゲストモードの場合は空の状態を表示
    if (isGuest) {
      return _buildEmptyState(
        icon: Icons.history,
        message: '参加履歴はログインユーザーのみ利用可能です',
      );
    }

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
      debugPrint('Error getting event topic: $e');
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
