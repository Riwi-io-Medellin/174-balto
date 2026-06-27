import 'package:dio/dio.dart';

import '../../domain/repositories/feedback_repository.dart';
import '../models/feedback_summary_dto.dart';

class FeedbackRemoteDataSource {
  FeedbackRemoteDataSource(this._dio);

  final Dio _dio;

  Future<FeedbackSummaryDto?> getByWalker(String walkerId) async {
    final response = await _dio.get<dynamic>('/feedback/walkers/$walkerId');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return FeedbackSummaryDto.fromJson(data);
    }

    if (status == 404) return null;

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw FeedbackFailure(data['code'] as String, data['error'] as String);
    }

    throw FeedbackFailure(
      'FEEDBACK_FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }
}
