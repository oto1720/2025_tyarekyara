import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings.freezed.dart';
part 'notification_settings.g.dart';

@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool isEnabled,
    @Default(9) int hour,
    @Default(0) int minute,
    @Default('トピックが届いています') String message,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}

/// 通知メッセージのプリセット
class NotificationMessages {
  static const List<String> messages = [
    'トピックが届いています',
    '今日のトピックをチェックしましょう',
    '新しいお題に挑戦してみませんか',
    'みんなの意見を見てみよう',
    'あなたの意見を聞かせてください',
  ];
}
