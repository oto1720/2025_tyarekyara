import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/debate_event.dart';
import '../../models/debate_match.dart';
import '../../providers/debate_event_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/entry_form.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/debate_event_unlock_provider.dart';

/// ディベートエントリー画面
class DebateEntryPage extends ConsumerStatefulWidget {
  final String eventId;

  const DebateEntryPage({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<DebateEntryPage> createState() => _DebateEntryPageState();
}

class _DebateEntryPageState extends ConsumerState<DebateEntryPage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    debugPrint('📄 DebateEntryPage build called for event: ${widget.eventId}');
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final authState = ref.watch(authControllerProvider);
    final unlockedAsync = ref.watch(isDebateEventUnlockedProvider(widget.eventId));

    return unlockedAsync.when(
      data: (unlocked) {
        if (!unlocked) {
          // アンロックされていない場合は詳細画面に戻す
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/debate/event/${widget.eventId}');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('エントリー設定'),
          ),
          body: eventAsync.when(
            data: (event) {
              if (event == null) {
                return _buildNotFound(context);
              }

              final userId = authState.maybeWhen(
                authenticated: (user) => user.id,
                orElse: () => null,
              );

              if (userId == null) {
                return _buildNotAuthenticated(context);
              }

              return _buildEntryForm(context, event, userId);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildError(context, error),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text('エントリー設定'),
        ),
        body: eventAsync.when(
          data: (event) {
            if (event == null) {
              return _buildNotFound(context);
            }

            final userId = authState.maybeWhen(
              authenticated: (user) => user.id,
              orElse: () => null,
            );

            if (userId == null) {
              return _buildNotAuthenticated(context);
            }

            return _buildEntryForm(context, event, userId);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(context, error),
        ),
      ),
    );
  }

  /// エントリーフォーム表示
  Widget _buildEntryForm(
    BuildContext context,
    DebateEvent event,
    String userId,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventInfo(event),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          EntryForm(
            event: event,
            onSubmit: ({
              required duration,
              required format,
              required stance,
            }) {
              _submitEntry(
                context,
                event,
                userId,
                duration,
                format,
                stance,
              );
            },
          ),
          const SizedBox(height: 24),
          _buildNotice(),
        ],
      ),
    );
  }

  /// イベント情報表示
  Widget _buildEventInfo(DebateEvent event) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.topic, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.topic,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
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

  /// 注意事項
  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '注意事項',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNoticeItem('エントリー後、マッチングが完了するまでお待ちください'),
          _buildNoticeItem('マッチング完了時に通知が届きます'),
          _buildNoticeItem('開始5分前までキャンセル可能です'),
          _buildNoticeItem('無断欠席はペナルティの対象となります'),
        ],
      ),
    );
  }

  /// 注意事項アイテム
  Widget _buildNoticeItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// エントリー送信
  Future<void> _submitEntry(
    BuildContext context,
    DebateEvent event,
    String userId,
    DebateDuration duration,
    DebateFormat format,
    DebateStance stance,
  ) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // エントリーを作成
      final entry = DebateEntry(
        userId: userId,
        eventId: event.id,
        preferredDuration: duration,
        preferredFormat: format,
        preferredStance: stance,
        enteredAt: DateTime.now(),
      );

      // リポジトリに保存
      final repository = ref.read(debateMatchRepositoryProvider);
      debugPrint('📝 Creating entry for event: ${event.id}');
      await repository.createEntry(entry);
      debugPrint('✅ Entry created successfully');

      // イベントの参加者数を更新
      try {
        final entryCount = await repository.getEntryCount(event.id);
        final eventRepository = ref.read(debateEventRepositoryProvider);
        await eventRepository.updateParticipantCount(event.id, entryCount);
      } catch (e) {
        debugPrint('Error updating participant count: $e');
        // エントリーは成功しているので、参加者数の更新エラーは無視
      }

      if (!context.mounted) return;

      // ウェイティングルームへ遷移
      debugPrint('🚀 Navigating to waiting room: /debate/event/${event.id}/waiting');
      context.pushReplacement('/debate/event/${event.id}/waiting');
      debugPrint('✅ Navigation triggered');
    } catch (e, stackTrace) {
      debugPrint('❌ Entry error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!context.mounted) return;

      // エラーダイアログ
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red, size: 60),
          title: const Text('エラー'),
          content: Text('エントリーに失敗しました。\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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

  /// 未認証表示
  Widget _buildNotAuthenticated(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 80, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'ログインが必要です',
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
}
