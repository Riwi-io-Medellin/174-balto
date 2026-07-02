import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/walk_media.dart';
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

  Future<List<LatLng>> getRoute(String sessionId) async {
    final response = await _dio.get<dynamic>('/walk-sessions/$sessionId/route');
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status == 200 && data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map((p) => LatLng(
                (p['latitude'] as num).toDouble(),
                (p['longitude'] as num).toDouble(),
              ))
          .toList();
    }
    _throwFailure(status, data);
  }

  Future<void> addMedia(String sessionId, String url, String type) async {
    final response = await _dio.post<dynamic>(
      '/walk-sessions/$sessionId/media',
      data: {'url': url, 'type': type},
    );
    final status = response.statusCode ?? 0;
    if (status == 200 || status == 201) return;
    _throwFailure(status, response.data);
  }

  Future<List<WalkMedia>> getSessionMedia(String sessionId) async {
    final response =
        await _dio.get<dynamic>('/walk-sessions/$sessionId/media');
    final status = response.statusCode ?? 0;
    final data = response.data;
    // ignore: avoid_print
    print('[WalkSession] getSessionMedia($sessionId) HTTP $status body: $data');

    // Accept bare list or common wrapper shapes: { data: [...] }, { items: [...] }
    List<dynamic>? list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data['items'] ?? data['media'];
      if (inner is List) list = inner;
    }

    if (status == 200 && list != null) {
      return list.map((raw) {
        final m = raw as Map<String, dynamic>;
        // ignore: avoid_print
        print('[WalkSession] media item: $m');
        final dateStr = (m['uploadedAt'] ?? m['createdAt'] ?? m['created_at'] ?? '') as String;
        return WalkMedia(
          id: (m['id'] ?? '').toString(),
          url: (m['url'] ?? m['mediaUrl'] ?? '') as String,
          type: (m['type'] ?? m['mediaType'] ?? 'photo') as String,
          uploadedAt: dateStr.isNotEmpty
              ? DateTime.tryParse(dateStr) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList();
    }
    _throwFailure(status, data);
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
    // ignore: avoid_print
    print('[WalkSession] HTTP $status — body: $data');
    throw WalkSessionFailure(
        'REQUEST_FAILED', 'Server error ($status). Check logs for details.');
  }
}
