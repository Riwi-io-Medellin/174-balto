import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/repositories/notification_repository.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import 'active_session_tracker.dart';

/// Types of push notification whose in-app banner should be suppressed while
/// the user already has the relevant walk session's live-tracking screen open.
const _sessionScopedTypes = {'chat_message', 'walk_media_uploaded'};

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No extra work needed: a "notification" payload is auto-displayed by the
  // OS while the app is backgrounded/terminated. This handler only needs to
  // exist so the plugin can register it.
}

class PushNotificationService {
  PushNotificationService(this._notificationRepository);

  final NotificationRepository _notificationRepository;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? navigatorKey;

  static const _channel = AndroidNotificationChannel(
    'balto_default_channel',
    'Balto notifications',
    description: 'Booking, walk, and chat updates from Balto.',
    importance: Importance.high,
  );

  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey}) async {
    this.navigatorKey = navigatorKey;

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _openNotifications();
      },
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((_) => _openNotifications());

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _openNotifications();

    FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
  }

  Future<void> registerCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _registerToken(token);
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  Future<void> unregisterCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _notificationRepository.removeDeviceToken(token);
    } catch (e) {
      debugPrint('Failed to unregister device token: $e');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _notificationRepository.registerDeviceToken(
        token: token,
        platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      );
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final entityId = data['entityId'];

    if (_sessionScopedTypes.contains(type) && ActiveSessionTracker.isActive(entityId)) {
      // Already visible in-app (live chat / media section) — don't duplicate.
      return;
    }

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'balto_default_channel',
          'Balto notifications',
          channelDescription: 'Booking, walk, and chat updates from Balto.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: type,
    );
  }

  void _openNotifications() {
    final navigator = navigatorKey?.currentState;
    if (navigator == null) return;
    navigator.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }
}
