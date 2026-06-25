import 'package:dio/dio.dart';

import '../../domain/repositories/pet_repository.dart';
import '../models/pet_dto.dart';

class PetRemoteDataSource {
  PetRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<PetDto>> getMyPets() async {
    final response = await _dio.get<dynamic>('/pets/me');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map((json) => PetDto.fromJson(json))
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
}
