import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getMyNotifications({
    bool? unreadOnly,
    int page = 1,
    int pageSize = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  });

  Future<void> removeDeviceToken(String token);
}

class NotificationFailure implements Exception {
  NotificationFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'NotificationFailure($code): $message';
}
