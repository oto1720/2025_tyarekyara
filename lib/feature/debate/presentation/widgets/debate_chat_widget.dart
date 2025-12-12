import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/debate_message.dart';
import '../../models/debate_room.dart';
import '../../models/debate_match.dart';
import '../../providers/debate_room_provider.dart';
import '../../../auth/providers/auth_provider.dart';

/// ディベートチャットWidget
class DebateChatWidget extends ConsumerStatefulWidget {
  final String roomId;
  final String userId;
  final MessageType messageType;
  final DebateStance? stance; // チームメッセージ用のスタンス

  const DebateChatWidget({
    super.key,
    required this.roomId,
    required this.userId,
    this.messageType = MessageType.public,
    this.stance,
  });

  @override
  ConsumerState<DebateChatWidget> createState() => _DebateChatWidgetState();
}

class _DebateChatWidgetState extends ConsumerState<DebateChatWidget> with AutomaticKeepAliveClientMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin のために必要
    // チームメッセージの場合はstanceでフィルタリング
    final messagesAsync = widget.messageType == MessageType.team && widget.stance != null
        ? ref.watch(teamMessagesWithStanceProvider((widget.roomId, widget.stance!)))
        : ref.watch(debateMessagesProvider((widget.roomId, widget.messageType)));

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            data: (messages) => _buildMessageList(messages),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('エラー: $error'),
            ),
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  /// メッセージリスト表示
  Widget _buildMessageList(List<DebateMessage> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'まだメッセージがありません',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // メッセージが追加されたら自動スクロール
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMyMessage = message.userId == widget.userId;
        return _buildMessageBubble(message, isMyMessage);
      },
    );
  }

  /// メッセージバブル
  Widget _buildMessageBubble(DebateMessage message, bool isMyMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            _buildAvatar(message),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMyMessage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 8),
                    child: Text(
                      message.userName ?? 'ユーザー',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _getMessageColor(message, isMyMessage),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMyMessage ? 16 : 4),
                      bottomRight: Radius.circular(isMyMessage ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          color: _getTextColor(message, isMyMessage),
                        ),
                      ),
                      if (message.hasWarning) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning,
                              size: 14,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '不適切な可能性',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            _buildAvatar(message),
          ],
        ],
      ),
    );
  }

  /// アバター
  Widget _buildAvatar(DebateMessage message) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.blue[100],
      child: Text(
        (message.userName ?? 'U')[0].toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  /// 入力エリア
  Widget _buildInputArea() {
    return GestureDetector(
      onTap: () {
        // 入力エリア全体がタップされたときにフォーカスを要求
        if (!_focusNode.hasFocus) {
          debugPrint('🎯 [InputArea] タップされました。フォーカスを要求します');
          _focusNode.requestFocus();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 120,
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    maxLines: null,
                    minLines: 1,
                    maxLength: 200,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    scrollPhysics: const BouncingScrollPhysics(),
                    decoration: InputDecoration(
                      hintText: 'メッセージを入力...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      counterText: '',
                    ),
                    onTap: () {
                      debugPrint('⌨️ [TextField] タップされました');
                      // フォーカスを明示的に要求
                      if (!_focusNode.hasFocus) {
                        _focusNode.requestFocus();
                      }
                    },
                    onSubmitted: (_) {
                      // TextInputAction.newlineのため、Enterキーで改行される
                      // 送信は送信ボタンのみで行う
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// メッセージ送信
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    // 送信時にProviderから最新のルーム情報を取得
    final room = ref.read(debateRoomByMatchProvider(widget.roomId)).value;
    if (room == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ルーム情報の取得に失敗し、送信できませんでした。'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // 現在のユーザー情報を取得
      final authState = ref.read(authControllerProvider);
      final userNickname = authState.maybeWhen(
        authenticated: (user) => user.nickname,
        orElse: () => null,
      );

      final message = DebateMessage(
        id: const Uuid().v4(),
        roomId: widget.roomId,
        userId: widget.userId,
        content: content,
        type: widget.messageType,
        phase: room.currentPhase, // 最新のフェーズ情報を使用
        createdAt: DateTime.now(),
        userNickname: userNickname,
        senderStance: widget.stance,
      );

      final repository = ref.read(debateRoomRepositoryProvider);
      await repository.sendMessage(message);

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('送信に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  /// メッセージ色取得
  Color _getMessageColor(DebateMessage message, bool isMyMessage) {
    if (message.type == MessageType.system) {
      return Colors.grey[200]!;
    }
    if (message.hasWarning) {
      return Colors.orange[50]!;
    }
    return isMyMessage ? Colors.blue[500]! : Colors.grey[200]!;
  }

  /// テキスト色取得
  Color _getTextColor(DebateMessage message, bool isMyMessage) {
    if (message.type == MessageType.system) {
      return Colors.grey[800]!;
    }
    return isMyMessage ? Colors.white : Colors.black87;
  }

  /// 時刻フォーマット
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
