import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/repositories/notification_repository.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/pets/lost_pet_report_screen.dart';
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

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    this.navigatorKey = navigatorKey;

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;
        final parts = payload.split('|');
        final type = parts.isNotEmpty ? parts[0] : null;
        final entityId = parts.length > 1 && parts[1].isNotEmpty
            ? parts[1]
            : null;
        final metadata = parts.length > 2 && parts[2].isNotEmpty
            ? parts[2]
            : null;
        _handleNotificationTap(
          type: type,
          entityId: entityId,
          metadata: metadata,
        );
      },
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleNotificationTap(
        type: message.data['type'],
        entityId: message.data['entityId'],
        metadata: message.data['metadata'],
      ),
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(
        type: initialMessage.data['type'],
        entityId: initialMessage.data['entityId'],
        metadata: initialMessage.data['metadata'],
      );
    }

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
        platform: defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      );
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final entityId = data['entityId'];

    if (_sessionScopedTypes.contains(type) &&
        ActiveSessionTracker.isActive(entityId)) {
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
      payload: '$type|${entityId ?? ''}|${data['metadata'] ?? ''}',
    );
  }

  void _handleNotificationTap({
    String? type,
    String? entityId,
    String? metadata,
  }) {
    final navigator = navigatorKey?.currentState;
    if (navigator == null) return;
    if (type == 'lost_pet' && entityId != null) {
      navigator.push(
        MaterialPageRoute(builder: (_) => LostPetReportScreen(petId: entityId)),
      );
      return;
    }
    if (type == 'pet_location_shared') {
      _openSharedLocationInMaps(metadata);
      return;
    }
    navigator.push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  Future<void> _openSharedLocationInMaps(String? metadata) async {
    if (metadata == null || metadata.isEmpty) return;
    try {
      final decoded = jsonDecode(metadata) as Map<String, dynamic>;
      final lat = decoded['latitude'];
      final lng = decoded['longitude'];
      if (lat == null || lng == null) return;
      final uri = Uri.parse(
        'https://maps.google.com/?q=$lat,$lng',
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to open shared location: $e');
    }
  }
}
