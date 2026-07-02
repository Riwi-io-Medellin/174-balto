import 'package:dio/dio.dart';

import '../../domain/repositories/feedback_repository.dart';
import '../models/feedback_summary_dto.dart';

class FeedbackRemoteDataSource {
  FeedbackRemoteDataSource(this._dio);

  final Dio _dio;

  Future<FeedbackSummaryDto?> getByWalker(String walkerId) async {
    final response = await _dio.get<dynamic>('/feedback/walkers/$walkerId');
    return _handleSummaryResponse(response);
  }

  Future<FeedbackSummaryDto?> getByBusiness(String businessId) async {
    final response = await _dio.get<dynamic>('/feedback/businesses/$businessId');
    return _handleSummaryResponse(response);
  }

  Future<FeedbackSummaryDto?> getByHomeServiceProvider(String providerId) async {
    final response =
        await _dio.get<dynamic>('/feedback/home-service-providers/$providerId');
    return _handleSummaryResponse(response);
  }

  Future<void> createWalkerReview({
    required String walkerId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'walkerId': walkerId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    final response = await _dio.post<dynamic>('/feedback/walkers', data: body);
    _ensureSuccess(response, 'FEEDBACK_CREATE_FAILED');
  }

  Future<void> createBusinessReview({
    required String businessId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'businessId': businessId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    final response = await _dio.post<dynamic>('/feedback/businesses', data: body);
    _ensureSuccess(response, 'FEEDBACK_CREATE_FAILED');
  }

  Future<void> createHomeServiceProviderReview({
    required String providerId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'providerId': providerId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    final response =
        await _dio.post<dynamic>('/feedback/home-service-providers', data: body);
    _ensureSuccess(response, 'FEEDBACK_CREATE_FAILED');
  }

  FeedbackSummaryDto? _handleSummaryResponse(Response<dynamic> response) {
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

  void _ensureSuccess(Response<dynamic> response, String failureCode) {
    final status = response.statusCode ?? 0;
    if (status == 200 || status == 201) return;

    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw FeedbackFailure(data['code'] as String, data['error'] as String);
    }

    throw FeedbackFailure(failureCode, 'Unexpected response ($status).');
  }
}
