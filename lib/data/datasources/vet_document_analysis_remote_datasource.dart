import 'package:dio/dio.dart';

import '../../domain/entities/pet_health_context.dart';
import '../../domain/entities/vet_document_analysis.dart';
import '../../domain/repositories/vet_document_analysis_repository.dart';

class VetDocumentAnalysisRemoteDataSource {
  VetDocumentAnalysisRemoteDataSource(this._dio);

  final Dio _dio;

  Future<VetDocumentAnalysisResult> analyze({
    required PetHealthContext context,
    required List<String> fileUrls,
  }) async {
    final body = context.toJson()..['fileUrls'] = fileUrls;

    final response = await _dio.post<dynamic>(
      '/vet-document-analysis',
      data: body,
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return VetDocumentAnalysisResult.fromJson(data);
    }

    _throwFailure(status, data);
  }

  Never _throwFailure(int status, dynamic data) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw VetDocumentAnalysisFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    switch (status) {
      case 502:
        throw const VetDocumentAnalysisFailure(
          'AI_PARSE_ERROR',
          'The analysis could not be understood. Please try again.',
        );
      case 503:
        throw const VetDocumentAnalysisFailure(
          'AI_UNAVAILABLE',
          'The analysis service is temporarily unavailable. Please try again shortly.',
        );
      default:
        throw VetDocumentAnalysisFailure(
          'REQUEST_FAILED',
          'Server error ($status). Please try again.',
        );
    }
  }
}
