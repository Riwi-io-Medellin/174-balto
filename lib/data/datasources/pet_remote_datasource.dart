import 'package:dio/dio.dart';

import '../../domain/repositories/pet_repository.dart';
import '../models/pet_dto.dart';

class PetRemoteDataSource {
  PetRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<PetDto>> getMyPets() async {
    final response = await _dio.get<dynamic>(
      '/pets/me',
      queryParameters: {'page': 1, 'pageSize': 100},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      final items = data['items'] as List? ?? [];
      return items
          .map((json) => PetDto.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    if (status == 200 && data is List) {
      return data
          .map((json) => PetDto.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw PetFailure(data['code'] as String, data['error'] as String);
    }

    throw PetFailure('PETS_FETCH_FAILED', 'Unexpected response ($status).');
  }

  Future<PetDto> getById(String id) async {
    final response = await _dio.get<dynamic>('/pets/$id');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return PetDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw PetFailure(data['code'] as String, data['error'] as String);
    }

    throw PetFailure('PET_FETCH_FAILED', 'Unexpected response ($status).');
  }

  Future<PetDto> create(Map<String, dynamic> request) async {
    final response = await _dio.post<dynamic>('/pets/', data: request);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 201 && data is Map<String, dynamic>) {
      return PetDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw PetFailure(data['code'] as String, data['error'] as String);
    }

    throw PetFailure('PET_CREATE_FAILED', 'Unexpected response ($status).');
  }

  Future<PetDto> update(String id, Map<String, dynamic> request) async {
    final response = await _dio.put<dynamic>('/pets/$id', data: request);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return PetDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw PetFailure(data['code'] as String, data['error'] as String);
    }

    throw PetFailure('PET_UPDATE_FAILED', 'Unexpected response ($status).');
  }

  Future<void> delete(String id) async {
    final response = await _dio.delete<dynamic>('/pets/$id');
    final status = response.statusCode ?? 0;

    if (status == 204) return;

    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw PetFailure(data['code'] as String, data['error'] as String);
    }

    throw PetFailure('PET_DELETE_FAILED', 'Unexpected response ($status).');
  }

  Future<PetDto> reportLost(
    String id, {
    required double lostLatitude,
    required double lostLongitude,
  }) async {
    final response = await _dio.post<dynamic>(
      '/pets/$id/report-lost',
      data: {'lostLatitude': lostLatitude, 'lostLongitude': lostLongitude},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return PetDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw PetFailure(data['code'] as String, data['error'] as String);
    }

    throw PetFailure(
      'PET_REPORT_LOST_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<PetDto> markFound(String id) async {
    final response = await _dio.post<dynamic>('/pets/$id/mark-found');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return PetDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw PetFailure(data['code'] as String, data['error'] as String);
    }

    throw PetFailure('PET_MARK_FOUND_FAILED', 'Unexpected response ($status).');
  }
}
