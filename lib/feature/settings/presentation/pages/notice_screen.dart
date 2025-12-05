import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_settings.dart';
import '../../providers/notification_provider.dart';
import '../widgets/notice_widgets.dart';

class NoticeScreen extends ConsumerWidget {
  const NoticeScreen({super.key});

  /// 時刻選択処理
  Future<void> _selectTime(
    BuildContext context,
    WidgetRef ref,
    int currentHour,
    int currentMinute,
  ) async {
    final picked = await TimePickerHelper.selectTime(
      context,
      initialHour: currentHour,
      initialMinute: currentMinute,
    );

    if (picked != null) {
      // 6:00-23:00の範囲内かチェック
      if (picked.hour >= 6 && picked.hour <= 23) {
        await ref
            .read(notificationSettingsProvider.notifier)
            .updateTime(picked.hour, picked.minute);
      } else {
        if (context.mounted) {
          _showErrorMessage(context, '通知時刻は6:00〜23:00の範囲で設定してください');
        }
      }
    }
  }

  /// テスト通知送信処理
  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref.read(notificationSettingsProvider.notifier).sendTestNotification();

    if (context.mounted) {
      _showSuccessMessage(context, 'テスト通知を送信しました');
    }
  }

  /// 成功メッセージ表示
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// エラーメッセージ表示
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '通知設定',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 通知ON/OFF
              _buildNotificationToggle(context, ref, settings),
              const SizedBox(height: 16),

              // 通知時刻設定
              _buildTimeSetting(context, ref, settings),
              const SizedBox(height: 16),

              // 通知メッセージ
              _buildMessageSetting(context, ref, settings),
              const SizedBox(height: 24),

              // テスト通知ボタン
              TestNotificationButton(
                isEnabled: settings.isEnabled,
                onPressed: () => _sendTestNotification(context, ref),
              ),
              const SizedBox(height: 16),

              // 説明テキスト
              _buildDescription(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// 通知ON/OFFスイッチ
  Widget _buildNotificationToggle(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        value: settings.isEnabled,
        onChanged: (value) async {
          await ref
              .read(notificationSettingsProvider.notifier)
              .toggleNotification(value);

          if (context.mounted) {
            _showSuccessMessage(
              context,
              value ? '通知をオンにしました' : '通知をオフにしました',
            );
          }
        },
        title: const Text(
          '通知を有効にする',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          settings.isEnabled
              ? '毎日${settings.hour}:${settings.minute.toString().padLeft(2, '0')}に通知します'
              : '通知は無効です',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        activeThumbColor: Theme.of(context).primaryColor,
      ),
    );
  }

  /// 通知時刻設定セクション
  Widget _buildTimeSetting(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            '通知時刻',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        NotificationTimeCard(
          hour: settings.hour,
          minute: settings.minute,
          isEnabled: settings.isEnabled,
          onTap: () => _selectTime(
            context,
            ref,
            settings.hour,
            settings.minute,
          ),
        ),
      ],
    );
  }

  /// 通知メッセージ設定セクション
  Widget _buildMessageSetting(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            '通知メッセージ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '受け取りたい通知の種類を選択',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ...NotificationMessages.messages.map((message) {
                  return NotificationMessageTile(
                    message: message,
                    isSelected: settings.message == message,
                    isEnabled: settings.isEnabled,
                    onTap: () async {
                      await ref
                          .read(notificationSettingsProvider.notifier)
                          .updateMessage(message);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 説明テキスト
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        '※ 通知は毎日設定した時刻に届きます。\n※ アプリを終了していても通知は届きます。',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          height: 1.5,
        ),
      ),
    );
  }
}
