import 'package:dio/dio.dart';

import '../../domain/repositories/walking_history_repository.dart';

class WalkingHistoryRemoteDataSource {
  WalkingHistoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getMyHistory() async {
    final response = await _dio.get<dynamic>('/walking-history/me');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data.cast<Map<String, dynamic>>();
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkingHistoryFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkingHistoryFailure(
      'HISTORY_FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }
}
