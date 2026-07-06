import 'package:dio/dio.dart';

import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<List<AppNotification>> getMyNotifications({
    bool? unreadOnly,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final dtos = await _remote.getNotifications(
        unreadOnly: unreadOnly,
        page: page,
        pageSize: pageSize,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    } on NotificationFailure {
      rethrow;
    } on DioException catch (e) {
      throw NotificationFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      return await _remote.getUnreadCount();
    } on NotificationFailure {
      rethrow;
    } on DioException catch (e) {
      throw NotificationFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _remote.markAsRead(id);
    } on NotificationFailure {
      rethrow;
    } on DioException catch (e) {
      throw NotificationFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _remote.markAllAsRead();
    } on NotificationFailure {
      rethrow;
    } on DioException catch (e) {
      throw NotificationFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> registerDeviceToken({required String token, required String platform}) async {
    try {
      await _remote.registerDeviceToken(token: token, platform: platform);
    } on NotificationFailure {
      rethrow;
    } on DioException catch (e) {
      throw NotificationFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> removeDeviceToken(String token) async {
    try {
      await _remote.removeDeviceToken(token);
    } on NotificationFailure {
      rethrow;
    } on DioException catch (e) {
      throw NotificationFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
