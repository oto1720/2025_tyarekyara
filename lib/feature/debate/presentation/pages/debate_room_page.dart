import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/debate_room.dart';
import '../../models/debate_match.dart';
import '../../models/debate_event.dart';
import '../../models/debate_message.dart';
import '../../providers/debate_room_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../providers/debate_event_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/phase_indicator_widget.dart';
import '../widgets/debate_chat_widget.dart';
import '../../../../core/constants/app_colors.dart';

/// ディベートルーム画面
class DebateRoomPage extends ConsumerStatefulWidget {
  final String matchId;

  const DebateRoomPage({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<DebateRoomPage> createState() => _DebateRoomPageState();
}

class _DebateRoomPageState extends ConsumerState<DebateRoomPage>
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
    // ゲストモックマッチの場合
    if (widget.matchId == 'guest_mock_match') {
      return FutureBuilder<bool>(
        future: SharedPreferences.getInstance()
            .then((prefs) => prefs.getBool('is_guest_mode') ?? false),
        builder: (context, snapshot) {
          final isGuest = snapshot.data ?? false;
          if (!isGuest) {
            return _buildNotFound(context);
          }
          return _buildGuestMockRoom(context);
        },
      );
    }

    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));
    final authStateAsync = ref.watch(authStateChangesProvider);

    final user = authStateAsync.value;
    final userId = user?.uid;

    if (userId == null) {
      return _buildNotAuthenticated(context);
    }

    return matchAsync.when(
      data: (match) {
        if (match == null) {
          return _buildNotFound(context);
        }

        final roomAsync = ref.watch(debateRoomByMatchProvider(widget.matchId));

        return roomAsync.when(
          data: (room) {
            if (room == null) {
              return _buildWaitingForRoom(context, match);
            }
            return _buildDebateRoom(context, room, match, userId);
          },
          loading: () => _buildLoading(),
          error: (error, stack) => _buildError(context, error),
        );
      },
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(context, error),
    );
  }

  /// ディベートルーム表示
  Widget _buildDebateRoom(
    BuildContext context,
    DebateRoom room,
    DebateMatch match,
    String userId,
  ) {
    // 判定フェーズに入ったら判定待機画面へ遷移
    if (room.currentPhase == DebatePhase.judgment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('🎯 判定フェーズ開始！判定待機画面へ遷移');
          context.pushReplacement('/debate/judgment/${widget.matchId}');
        }
      });
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI判定待機画面へ遷移中...'),
          ],
        ),
      );
    }

    // 結果フェーズに入ったら結果画面へ遷移
    if (room.currentPhase == DebatePhase.result ||
        room.currentPhase == DebatePhase.completed ||
        room.status == RoomStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('🎯 結果フェーズ開始！結果画面へ遷移');
          context.pushReplacement('/debate/result/${widget.matchId}');
        }
      });
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('結果画面へ遷移中...'),
          ],
        ),
      );
    }

    final myStance = room.participantStances[userId];

    // イベント情報を取得
    final eventAsync = ref.watch(eventDetailProvider(match.eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ディベートルーム'),
        automaticallyImplyLeading: false, // 戻るボタンを非表示
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            room.currentPhase.displayName,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _PhaseTimerWidget(
                  room: room,
                  match: match,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildRoomHeader(room, match, userId, eventAsync.value),
          const Divider(height: 1),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPublicChat(room, userId),
                if (myStance != null)
                  _buildTeamChat(room, userId, myStance)
                else
                  const Center(child: Text('チャットに参加できません')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ルームヘッダー
  Widget _buildRoomHeader(
    DebateRoom room,
    DebateMatch match,
    String userId,
    DebateEvent? event,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          // トピック表示
          if (event != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.topic,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '今日のトピック',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.topic,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _buildTeamInfo(
                  match.proTeam,
                  '賛成',
                  Colors.blue,
                  userId,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Icon(Icons.compare_arrows, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildTeamInfo(
                  match.conTeam,
                  '反対',
                  Colors.red,
                  userId,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PhaseProgressBar(currentPhase: room.currentPhase),
        ],
      ),
    );
  }

  /// チーム情報
  Widget _buildTeamInfo(
    DebateTeam team,
    String label,
    Color color,
    String userId,
  ) {
    final isMyTeam = team.memberIds.contains(userId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMyTeam ? color.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyTeam ? color : Colors.grey[300]!,
          width: isMyTeam ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isMyTeam)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'あなたのチーム',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isMyTeam) const SizedBox(height: 8),
          Icon(
            team.stance == DebateStance.pro
                ? Icons.thumb_up
                : Icons.thumb_down,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${team.memberIds.length}人',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// タブバー
  Widget _buildTabBar() {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        indicatorColor: AppColors.primary,
        onTap: (index) {
          debugPrint('🔵 [TabBar] タブがタップされました: $index');
        },
        tabs: const [
          Tab(
            icon: Icon(Icons.public),
            text: '公開チャット',
          ),
          Tab(
            icon: Icon(Icons.groups),
            text: 'チームチャット',
          ),
        ],
      ),
    );
  }

  /// 公開チャット
  Widget _buildPublicChat(DebateRoom room, String userId) {
    return DebateChatWidget(
      roomId: room.id,
      userId: userId,
      currentPhase: room.currentPhase,
      messageType: MessageType.public,
    );
  }

  /// チームチャット
  Widget _buildTeamChat(DebateRoom room, String userId, DebateStance stance) {
    return DebateChatWidget(
      roomId: room.id,
      userId: userId,
      currentPhase: room.currentPhase,
      messageType: MessageType.team,
      stance: stance, // チームのスタンスを渡してフィルタリング
    );
  }

  /// ルーム待機中
  Widget _buildWaitingForRoom(BuildContext context, DebateMatch match) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ディベート準備中'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'ディベートルームを準備しています...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'しばらくお待ちください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ローディング
  Widget _buildLoading() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  /// 未認証
  Widget _buildNotAuthenticated(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('エラー')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('ログインが必要です'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }

  /// 見つからない
  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('エラー')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('マッチが見つかりません'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }

  /// エラー
  Widget _buildError(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(title: const Text('エラー')),
      body: Center(
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
      ),
    );
  }

  /// ゲスト用のモックディベートルームを表示
  Widget _buildGuestMockRoom(BuildContext context) {
    final now = DateTime.now();
    final mockMatch = DebateMatch(
      id: 'guest_mock_match',
      eventId: 'guest_mock_event',
      proTeam: DebateTeam(
        memberIds: ['guest'],
        stance: DebateStance.pro,
      ),
      conTeam: DebateTeam(
        memberIds: ['mock_opponent'],
        stance: DebateStance.con,
      ),
      status: MatchStatus.inProgress,
      format: DebateFormat.oneVsOne,
      duration: DebateDuration.short,
      matchedAt: now,
      startedAt: now,
      createdAt: now,
    );

    final mockRoom = DebateRoom(
      id: 'guest_mock_room',
      eventId: 'guest_mock_event',
      matchId: 'guest_mock_match',
      participantIds: ['guest', 'mock_opponent'],
      participantStances: {
        'guest': DebateStance.pro,
        'mock_opponent': DebateStance.con,
      },
      status: RoomStatus.inProgress,
      currentPhase: DebatePhase.preparation,
      phaseStartedAt: now,
      phaseTimeRemaining: 300,
      createdAt: now,
      updatedAt: now,
    );

    return _GuestMockDebateRoom(
      room: mockRoom,
      match: mockMatch,
      tabController: _tabController,
    );
  }
}

/// フェーズタイマーWidget（ルームの変更を監視）
class _PhaseTimerWidget extends StatefulWidget {
  final DebateRoom room;
  final DebateMatch match;

  const _PhaseTimerWidget({
    required this.room,
    required this.match,
  });

  @override
  State<_PhaseTimerWidget> createState() => _PhaseTimerWidgetState();
}

class _PhaseTimerWidgetState extends State<_PhaseTimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _startTimer();
  }

  @override
  void didUpdateWidget(_PhaseTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // フェーズが変わったらタイマーをリセット
    if (oldWidget.room.currentPhase != widget.room.currentPhase ||
        oldWidget.room.phaseStartedAt != widget.room.phaseStartedAt ||
        oldWidget.room.phaseTimeRemaining != widget.room.phaseTimeRemaining) {
      debugPrint('🔄 タイマーリセット: phase=${widget.room.currentPhase.name}, phaseStartedAt=${widget.room.phaseStartedAt?.toString() ?? "null"}');
      _updateRemainingTime();
      // タイマーを再起動
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    // フェーズの最大時間を取得
    final maxDuration = widget.match.duration == DebateDuration.short
        ? widget.room.currentPhase.shortDuration
        : widget.room.currentPhase.mediumDuration;
    
    if (widget.room.phaseStartedAt != null) {
      // phaseStartedAtから経過時間を計算
      final now = DateTime.now();
      final phaseStart = widget.room.phaseStartedAt!;
      final elapsed = now.difference(phaseStart).inSeconds;
      
      // 残り時間を計算
      final remaining = maxDuration - elapsed;
      _remainingSeconds = remaining > 0 ? remaining : 0;
      
      debugPrint('⏱️ タイマー更新: phaseStartedAt=${phaseStart.toString()}, elapsed=$elapsed秒, maxDuration=$maxDuration秒, remaining=$_remainingSeconds秒');
    } else {
      // phaseStartedAtがない場合は、phaseTimeRemainingを使用（0の場合は最大時間を使用）
      if (widget.room.phaseTimeRemaining > 0) {
        _remainingSeconds = widget.room.phaseTimeRemaining;
      } else {
        // phaseTimeRemainingが0の場合は、フェーズの最大時間を使用
        _remainingSeconds = maxDuration;
      }
      
      debugPrint('⏱️ タイマー更新: phaseStartedAt=null, phaseTimeRemaining=${widget.room.phaseTimeRemaining}, maxDuration=$maxDuration, using=$_remainingSeconds秒');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    
    if (_remainingSeconds <= 0) {
      debugPrint('⚠️ タイマー開始スキップ: 残り時間が0以下です ($_remainingSeconds秒)');
      return;
    }
    
    debugPrint('▶️ タイマー開始: $_remainingSeconds秒');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          if (_remainingSeconds % 10 == 0 || _remainingSeconds <= 5) {
            debugPrint('⏱️ タイマー: $_remainingSeconds秒');
          }
        } else {
          timer.cancel();
          debugPrint('⏰ タイマー終了');
          // タイマー終了時はFirestoreの更新を待つ（Cloud Functionsが処理）
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final isWarning = _remainingSeconds <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning ? AppColors.error : AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: AppColors.textOnPrimary, size: 16),
          const SizedBox(width: 6),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// ゲスト用のモックディベートルームWidget
class _GuestMockDebateRoom extends StatefulWidget {
  final DebateRoom room;
  final DebateMatch match;
  final TabController tabController;

  const _GuestMockDebateRoom({
    required this.room,
    required this.match,
    required this.tabController,
  });

  @override
  State<_GuestMockDebateRoom> createState() => _GuestMockDebateRoomState();
}

class _GuestMockDebateRoomState extends State<_GuestMockDebateRoom> {
  late int _remainingSeconds;
  Timer? _timer;
  final List<DebateMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.room.phaseTimeRemaining > 0
        ? widget.room.phaseTimeRemaining
        : 300; // 5分
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          // 時間切れ：結果画面へ遷移
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.pushReplacement('/debate/result/guest_mock_match');
            }
          });
        }
      });
    });
  }

  void _sendMessage(String content) {
    final newMessage = DebateMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      roomId: widget.room.id,
      userId: 'guest',
      userNickname: 'ゲスト',
      content: content,
      type: MessageType.public,
      phase: widget.room.currentPhase,
      createdAt: DateTime.now(),
      senderStance: DebateStance.pro,
    );

    setState(() {
      _messages.add(newMessage);
    });

    // 5秒後にAI相手からの返信を追加
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final aiResponse = DebateMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        roomId: widget.room.id,
        userId: 'mock_opponent',
        userNickname: 'AI相手',
        content: 'なるほど、興味深い視点ですね。しかし、別の観点から考えると...',
        type: MessageType.public,
        phase: widget.room.currentPhase,
        createdAt: DateTime.now(),
        senderStance: DebateStance.con,
      );
      setState(() {
        _messages.add(aiResponse);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final isWarning = _remainingSeconds <= 10;

    return Scaffold(
        appBar: AppBar(
          title: const Text('お試しディベート'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
        children: [
          // ヘッダー部分
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // タイマー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ディベート中',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isWarning ? Colors.red : AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // トピック
                const Text(
                  '環境保護のために個人の利便性を犠牲にすべきか',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // チーム情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTeamInfo('賛成', 'ゲスト', Colors.blue),
                    const Text('vs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildTeamInfo('反対', 'AI相手', Colors.red),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // メッセージリスト
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'メッセージを送信してディベートを始めましょう',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMyMessage = message.userId == 'guest';
                      return _buildMessageBubble(message, isMyMessage);
                    },
                  ),
          ),
          // 入力エリア
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 120,
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'メッセージを入力...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        _sendMessage(_messageController.text.trim());
                        _messageController.clear();
                      }
                    },
                    icon: const Icon(Icons.send),
                    color: AppColors.primary,
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String stance, String name, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            stance,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(DebateMessage message, bool isMyMessage) {
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMyMessage ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.userNickname ?? message.userId,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isMyMessage ? Colors.white : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14,
                color: isMyMessage ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
