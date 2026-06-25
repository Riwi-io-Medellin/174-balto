import 'package:dio/dio.dart';

import '../../domain/repositories/user_repository.dart';
import '../models/user_dto.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserDto> getById(String id) async {
    final response = await _dio.get<dynamic>('/users/$id');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return UserDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw UserFailure(data['code'] as String, data['error'] as String);
    }

    throw UserFailure('USER_FETCH_FAILED', 'Unexpected response ($status).');
  }

  Future<UserDto> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.put<dynamic>('/users/$id', data: data);
    final status = response.statusCode ?? 0;
    final body = response.data;

    if (status == 200 && body is Map<String, dynamic>) {
      return UserDto.fromJson(body);
    }

    if (body is Map<String, dynamic> &&
        body['code'] is String &&
        body['error'] is String) {
      throw UserFailure(body['code'] as String, body['error'] as String);
    }

    throw UserFailure('USER_UPDATE_FAILED', 'Unexpected response ($status).');
  }
}
