import 'package:dio/dio.dart';

import '../../domain/repositories/auth_repository.dart';
import '../models/auth_tokens_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthTokensDto> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String idNumber,
    required String idType,
    required String phone,
  }) async {
    final response = await _dio.post<dynamic>(
      '/auth/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'idNumber': idNumber,
        'idType': idType,
        'phone': phone,
      },
    );
    return _parseTokenResponse(response, expectedStatus: 201);
  }

  Future<AuthTokensDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return _parseTokenResponse(response, expectedStatus: 200);
  }

  Future<AuthTokensDto> refresh({required String refreshToken}) async {
    final response = await _dio.post<dynamic>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return _parseTokenResponse(response, expectedStatus: 200);
  }

  Future<void> logout({required String refreshToken}) async {
    await _dio.post<dynamic>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dio.post<dynamic>(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    final status = response.statusCode ?? 0;
    if (status == 204) return;

    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw AuthFailure(data['code'] as String, data['error'] as String);
    }
    throw AuthFailure('CHANGE_PASSWORD_FAILED', 'Unexpected response ($status).');
  }

  AuthTokensDto _parseTokenResponse(
    Response<dynamic> response, {
    required int expectedStatus,
  }) {
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == expectedStatus && data is Map<String, dynamic>) {
      return AuthTokensDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw AuthFailure(data['code'] as String, data['error'] as String);
    }

    throw AuthFailure('AUTH_FAILED', 'Unexpected response ($status).');
  }
}
