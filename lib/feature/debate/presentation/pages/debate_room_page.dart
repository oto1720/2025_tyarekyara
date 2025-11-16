import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../models/debate_room.dart';
import '../../models/debate_match.dart';
import '../../models/debate_event.dart';
import '../../models/debate_message.dart';
import '../../providers/debate_room_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/phase_indicator_widget.dart';
import '../widgets/debate_chat_widget.dart';

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
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));
    final authState = ref.watch(authControllerProvider);

    final userId = authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );

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
          print('🎯 判定フェーズ開始！判定待機画面へ遷移');
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
          print('🎯 結果フェーズ開始！結果画面へ遷移');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('ディベートルーム'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // 戻るボタンを非表示
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.blue[700],
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: PhaseIndicatorWidget(
                    currentPhase: room.currentPhase,
                    isCompact: true,
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
          _buildRoomHeader(room, match, userId),
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
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        children: [
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
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
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
      print('🔄 タイマーリセット: phase=${widget.room.currentPhase.name}, phaseStartedAt=${widget.room.phaseStartedAt?.toString() ?? "null"}');
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
      
      print('⏱️ タイマー更新: phaseStartedAt=${phaseStart.toString()}, elapsed=${elapsed}秒, maxDuration=${maxDuration}秒, remaining=${_remainingSeconds}秒');
    } else {
      // phaseStartedAtがない場合は、phaseTimeRemainingを使用（0の場合は最大時間を使用）
      if (widget.room.phaseTimeRemaining > 0) {
        _remainingSeconds = widget.room.phaseTimeRemaining;
      } else {
        // phaseTimeRemainingが0の場合は、フェーズの最大時間を使用
        _remainingSeconds = maxDuration;
      }
      
      print('⏱️ タイマー更新: phaseStartedAt=null, phaseTimeRemaining=${widget.room.phaseTimeRemaining}, maxDuration=${maxDuration}, using=${_remainingSeconds}秒');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    
    if (_remainingSeconds <= 0) {
      print('⚠️ タイマー開始スキップ: 残り時間が0以下です (${_remainingSeconds}秒)');
      return;
    }
    
    print('▶️ タイマー開始: ${_remainingSeconds}秒');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          if (_remainingSeconds % 10 == 0 || _remainingSeconds <= 5) {
            print('⏱️ タイマー: ${_remainingSeconds}秒');
          }
        } else {
          timer.cancel();
          print('⏰ タイマー終了');
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
        color: isWarning ? Colors.red : Colors.blue,
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
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
