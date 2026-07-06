import 'package:dio/dio.dart';

import '../../domain/repositories/notification_repository.dart';
import '../models/notification_dto.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<AppNotificationDto>> getNotifications({
    bool? unreadOnly,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (unreadOnly == true) {
      queryParams['unreadOnly'] = true;
    }

    final response = await _dio.get<dynamic>(
      '/notifications',
      queryParameters: queryParams,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      final items = data['notifications'] as List? ?? [];
      return items
          .cast<Map<String, dynamic>>()
          .map((e) => AppNotificationDto.fromJson(e))
          .toList();
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw NotificationFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw NotificationFailure(
      'NOTIFICATIONS_FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get<dynamic>('/notifications/unread-count');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return (data['unreadCount'] as num).toInt();
    }

    throw NotificationFailure(
      'UNREAD_COUNT_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<void> markAsRead(String id) async {
    final response = await _dio.post<dynamic>('/notifications/$id/read');
    final status = response.statusCode ?? 0;

    if (status == 200) return;

    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw NotificationFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw NotificationFailure(
      'MARK_READ_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<void> markAllAsRead() async {
    final response = await _dio.post<dynamic>('/notifications/read-all');
    final status = response.statusCode ?? 0;

    if (status == 200) return;

    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw NotificationFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw NotificationFailure(
      'MARK_ALL_READ_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<void> registerDeviceToken({required String token, required String platform}) async {
    final response = await _dio.post<dynamic>(
      '/notifications/device-token',
      data: {'token': token, 'platform': platform},
    );
    final status = response.statusCode ?? 0;
    if (status == 204) return;

    throw NotificationFailure(
      'DEVICE_TOKEN_REGISTER_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<void> removeDeviceToken(String token) async {
    final response = await _dio.post<dynamic>(
      '/notifications/device-token/remove',
      data: {'token': token},
    );
    final status = response.statusCode ?? 0;
    if (status == 204) return;

    throw NotificationFailure(
      'DEVICE_TOKEN_REMOVE_FAILED',
      'Unexpected response ($status).',
    );
  }
}
