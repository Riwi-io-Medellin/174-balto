import 'package:dio/dio.dart';

import '../../domain/repositories/walk_session_repository.dart';

class WalkSessionRemoteDataSource {
  WalkSessionRemoteDataSource(this._dio);

  final Dio _dio;

  Future<String> startSession(String bookingId) async {
    final response = await _dio.post<dynamic>(
      '/walk-sessions/start',
      data: {'bookingId': bookingId},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return data['id'] as String;
    }

    _throwFailure(status, data);
  }

  Future<void> addLocation(
      String sessionId, double latitude, double longitude) async {
    final response = await _dio.post<dynamic>(
      '/walk-sessions/$sessionId/location',
      data: {'latitude': latitude, 'longitude': longitude},
    );
    final status = response.statusCode ?? 0;
    if (status == 200 || status == 201) return;
    _throwFailure(status, response.data);
  }

  Future<void> finishSession(
      String sessionId, double totalDistanceMeters, int totalDurationSeconds) async {
    final response = await _dio.post<dynamic>(
      '/walk-sessions/$sessionId/finish',
      data: {
        'totalDistanceMeters': totalDistanceMeters,
        'totalDurationSeconds': totalDurationSeconds,
      },
    );
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Never _throwFailure(int status, dynamic data) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkSessionFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw WalkSessionFailure(
        'REQUEST_FAILED', 'Unexpected response ($status).');
  }
}
