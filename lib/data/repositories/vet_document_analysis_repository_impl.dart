import 'package:dio/dio.dart';

import '../../domain/entities/pet_health_context.dart';
import '../../domain/entities/vet_document_analysis.dart';
import '../../domain/repositories/vet_document_analysis_repository.dart';
import '../datasources/vet_document_analysis_remote_datasource.dart';

class VetDocumentAnalysisRepositoryImpl implements VetDocumentAnalysisRepository {
  VetDocumentAnalysisRepositoryImpl(this._remote);

  final VetDocumentAnalysisRemoteDataSource _remote;

  @override
  Future<VetDocumentAnalysisResult> analyze({
    required PetHealthContext context,
    required List<String> fileUrls,
  }) async {
    try {
      return await _remote.analyze(context: context, fileUrls: fileUrls);
    } on VetDocumentAnalysisFailure {
      rethrow;
    } on DioException catch (e) {
      final isTimeout = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      throw VetDocumentAnalysisFailure(
        isTimeout ? 'TIMEOUT' : 'NETWORK_ERROR',
        isTimeout
            ? 'The analysis is taking longer than expected. Please try again.'
            : e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<VetDocumentAnalysisHistoryItem>> getHistory(String petId) async {
    try {
      return await _remote.getHistory(petId);
    } on VetDocumentAnalysisFailure {
      rethrow;
    } on DioException catch (e) {
      throw VetDocumentAnalysisFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
