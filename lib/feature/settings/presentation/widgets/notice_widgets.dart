import 'package:flutter/material.dart';

/// 通知メッセージ選択ラジオボタン
class NotificationMessageTile extends StatelessWidget {
  final String message;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  const NotificationMessageTile({
    super.key,
    required this.message,
    required this.isSelected,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: isEnabled
                        ? (isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black87)
                        : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 通知時刻表示カード
class NotificationTimeCard extends StatelessWidget {
  final int hour;
  final int minute;
  final bool isEnabled;
  final VoidCallback? onTap;

  const NotificationTimeCard({
    super.key,
    required this.hour,
    required this.minute,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      child: ListTile(
        enabled: isEnabled,
        onTap: isEnabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isEnabled
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.access_time,
            color: isEnabled
                ? Theme.of(context).primaryColor
                : Colors.grey[400],
            size: 24,
          ),
        ),
        title: Text(
          '$hour:${minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isEnabled ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          '6:00〜23:00の範囲で設定できます',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isEnabled ? Colors.grey[400] : Colors.grey[300],
        ),
      ),
    );
  }
}

/// テスト通知ボタン
class TestNotificationButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;

  const TestNotificationButton({
    super.key,
    required this.isEnabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: const Icon(Icons.notifications_active),
          label: const Text(
            'テスト通知を送信',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
            side: BorderSide(
              color: isEnabled
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

/// 時刻選択ダイアログヘルパー
class TimePickerHelper {
  static Future<TimeOfDay?> selectTime(
    BuildContext context, {
    required int initialHour,
    required int initialMinute,
  }) async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialEntryMode: TimePickerEntryMode.input,
      helpText: '通知時刻を選択',
      hourLabelText: '時',
      minuteLabelText: '分',
    );
  }
}
