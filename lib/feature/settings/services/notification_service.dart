import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart' hide NotificationSettings;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/notification_settings.dart';

/// バックグラウンドメッセージハンドラー（トップレベル関数である必要がある）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
}

/// ローカル通知を管理するサービス
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;
  String? _fcmToken;

  // 通知タップ時のコールバック
  Function(String? matchId)? onMatchNotificationTapped;

  /// 通知サービスを初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    // タイムゾーンデータを初期化
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

    // Android設定
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS設定
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // FCMの初期化
    await _initializeFCM();

    _isInitialized = true;
  }

  /// FCMを初期化
  Future<void> _initializeFCM() async {
    // FCM権限をリクエスト
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM authorization granted');

      // FCMトークンを取得（iOSではAPNSトークンが準備できるまで待つ必要がある）
      try {
        _fcmToken = await _messaging.getToken();
        print('FCM Token: $_fcmToken');
      } on FirebaseException catch (e) {
        // iOSでAPNSトークンがまだ準備できていない場合はエラーを無視
        if (e.code == 'apns-token-not-set') {
          print('APNSトークンがまだ準備できていません（後でonTokenRefreshで取得されます）');
        } else {
          print('FCM Token取得エラー: ${e.code} - ${e.message}');
        }
      } catch (e) {
        // その他のエラー
        print('FCM Token取得エラー（後でリトライされます）: $e');
      }

      // トークン更新を監視（APNSトークンが準備できた時に自動的に呼ばれる）
      _messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        print('FCM Token refreshed: $token');
      });

      // フォアグラウンドメッセージを処理
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 通知タップでアプリが開かれた時の処理
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // アプリが終了状態から通知で開かれた場合
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    }
  }

  /// フォアグラウンドメッセージを処理
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.notification?.title}');

    // ローカル通知を表示
    if (message.notification != null) {
      final matchId = message.data['matchId'] as String?;
      showMatchNotification(
        title: message.notification!.title ?? 'マッチング成立',
        body: message.notification!.body ?? '対戦相手が見つかりました',
        matchId: matchId,
      );
    }
  }

  /// 通知タップでアプリが開かれた時の処理
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.data}');
    final matchId = message.data['matchId'] as String?;
    if (matchId != null) {
      onMatchNotificationTapped?.call(matchId);
    }
  }

  /// FCMトークンをFirestoreに保存
  Future<void> saveFcmToken(String userId) async {
    if (_fcmToken == null) {
      try {
        _fcmToken = await _messaging.getToken();
      } on FirebaseException catch (e) {
        // iOSでAPNSトークンがまだ準備できていない場合はエラーを無視
        if (e.code == 'apns-token-not-set') {
          print('APNSトークンがまだ準備できていません。トークンは後で保存されます。');
          return;
        } else {
          print('FCM Token取得エラー: ${e.code} - ${e.message}');
          return;
        }
      } catch (e) {
        print('FCM Token取得エラー: $e');
        return;
      }
    }

    if (_fcmToken != null) {
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('FCM token saved for user: $userId');
    }
  }

  /// FCMトークンを削除（ログアウト時）
  Future<void> removeFcmToken(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': FieldValue.delete(),
      'fcmTokenUpdatedAt': FieldValue.delete(),
    });
    print('FCM token removed for user: $userId');
  }

  /// マッチング通知を表示
  Future<void> showMatchNotification({
    required String title,
    required String body,
    String? matchId,
  }) async {
    await _notifications.show(
      100, // マッチング通知用ID
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'match_notification',
          'マッチング通知',
          channelDescription: 'マッチング成立時に通知を受け取ります',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: matchId,
    );
  }

  /// 通知がタップされた時の処理
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // マッチング通知の場合
    if (response.payload != null && response.payload!.isNotEmpty) {
      onMatchNotificationTapped?.call(response.payload);
    }
  }

  /// 通知権限をリクエスト
  Future<bool> requestPermission() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// 毎日の通知をスケジュール
  Future<void> scheduleDailyNotification(NotificationSettings settings) async {
    if (!settings.isEnabled) {
      await cancelAllNotifications();
      return;
    }

    await _notifications.cancel(0); // 既存の通知をキャンセル

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.hour,
      settings.minute,
    );

    // 指定時刻が既に過ぎている場合は明日にスケジュール
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0, // 通知ID
      'チャレキャラ', // 通知タイトル
      settings.message, // 通知本文
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification',
          '毎日の通知',
          channelDescription: '毎日決まった時間に通知を受け取ります',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 毎日同じ時刻に繰り返す
    );
  }

  /// すべての通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// テスト通知を即座に表示
  Future<void> showTestNotification(String message) async {
    await _notifications.show(
      999, // テスト通知用ID
      'チャレキャラ',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification',
          'テスト通知',
          channelDescription: '通知のテスト用',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// スケジュールされた通知を取得（デバッグ用）
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
