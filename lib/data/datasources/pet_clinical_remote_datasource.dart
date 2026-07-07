import 'package:dio/dio.dart';

import '../../domain/repositories/pet_clinical_repository.dart';

class PetClinicalRemoteDataSource {
  PetClinicalRemoteDataSource(this._dio);

  final Dio _dio;

  Future<String> registerDocument(
    String petId, {
    required String fileUrl,
    required String fileName,
    required String fileType,
  }) async {
    final response = await _dio.post<dynamic>(
      '/pets/$petId/clinical-record/documents',
      data: {'fileUrl': fileUrl, 'fileName': fileName, 'fileType': fileType},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 201 && data is Map<String, dynamic>) {
      return data['documentId'] as String;
    }
    throw _failureFrom(data, status, 'REGISTER_DOCUMENT_FAILED');
  }

  Future<Map<String, dynamic>> runExtraction(
    String petId,
    List<String> documentIds,
  ) async {
    final response = await _dio.post<dynamic>(
      '/pets/$petId/clinical-record/documents/extract',
      data: {'documentIds': documentIds},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return data;
    }
    throw _failureFrom(data, status, 'EXTRACTION_FAILED');
  }

  Future<Map<String, dynamic>> confirmEvent(
    String petId,
    Map<String, dynamic> request,
  ) async {
    final response = await _dio.post<dynamic>(
      '/pets/$petId/clinical-record/events',
      data: request,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 201 && data is Map<String, dynamic>) {
      return data;
    }
    throw _failureFrom(data, status, 'CONFIRM_EVENT_FAILED');
  }

  Future<Map<String, dynamic>> getRecord(String petId) async {
    final response = await _dio.get<dynamic>('/pets/$petId/clinical-record');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return data;
    }
    throw _failureFrom(data, status, 'GET_RECORD_FAILED');
  }

  Future<List<dynamic>> getTips(String petId) async {
    final response = await _dio.get<dynamic>(
      '/pets/$petId/clinical-record/tips',
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data;
    }
    throw _failureFrom(data, status, 'GET_TIPS_FAILED');
  }

  PetClinicalFailure _failureFrom(
    dynamic data,
    int status,
    String fallbackCode,
  ) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      return PetClinicalFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    return PetClinicalFailure(fallbackCode, 'Unexpected response ($status).');
  }
}
