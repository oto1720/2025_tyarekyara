import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

/// 通知サービスのプロバイダー
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// 通知設定を管理するNotifier
class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  late final NotificationService _notificationService;
  static const String _storageKey = 'notification_settings';

  @override
  NotificationSettings build() {
    _notificationService = ref.read(notificationServiceProvider);
    _loadSettings();
    _initializeNotificationService();
    return const NotificationSettings();
  }

  /// 通知サービスを初期化
  Future<void> _initializeNotificationService() async {
    await _notificationService.initialize();
    await _notificationService.requestPermission();
  }

  /// 設定をSharedPreferencesから読み込む
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = NotificationSettings.fromJson(json);

        // 通知をスケジュール
        await _notificationService.scheduleDailyNotification(state);
      } else {
        // 初回起動時：デフォルト設定で通知をスケジュール
        await _notificationService.scheduleDailyNotification(state);
        await _saveSettings();
      }
    } catch (e) {
      debugPrint('設定の読み込みに失敗しました: $e');
    }
  }

  /// 設定をSharedPreferencesに保存
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('設定の保存に失敗しました: $e');
      rethrow;
    }
  }

  /// 通知のON/OFFを切り替え
  Future<void> toggleNotification(bool isEnabled) async {
    state = state.copyWith(isEnabled: isEnabled);
    await _saveSettings();
    await _notificationService.scheduleDailyNotification(state);
  }

  /// 通知時刻を変更
  Future<void> updateTime(int hour, int minute) async {
    state = state.copyWith(hour: hour, minute: minute);
    await _saveSettings();
    await _notificationService.scheduleDailyNotification(state);
  }

  /// 通知メッセージを変更
  Future<void> updateMessage(String message) async {
    state = state.copyWith(message: message);
    await _saveSettings();
    await _notificationService.scheduleDailyNotification(state);
  }

  /// テスト通知を送信
  Future<void> sendTestNotification() async {
    await _notificationService.showTestNotification(state.message);
  }

  /// スケジュールされた通知を確認（デバッグ用）
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }
}

/// 通知設定のプロバイダー
final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
