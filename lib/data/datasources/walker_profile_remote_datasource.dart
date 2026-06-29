import 'package:dio/dio.dart';

import '../../domain/repositories/walker_profile_repository.dart';
import '../models/walker_profile_dto.dart';

class WalkerProfileRemoteDataSource {
  WalkerProfileRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /walkers/me — returns null when the user has no walker profile (404).
  Future<WalkerProfileDto?> getMe() async {
    final response = await _dio.get<dynamic>('/walkers/me');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 404) return null;

    if (status == 200 && data is Map<String, dynamic>) {
      return WalkerProfileDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerProfileFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerProfileFailure(
      'FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }

  /// POST /walkers/apply — multipart upload with document + profile info.
  Future<WalkerProfileDto> apply({
    required String filePath,
    required String workLocation,
    required String experience,
    String? description,
  }) async {
    final formData = FormData.fromMap({
      'document': await MultipartFile.fromFile(
        filePath,
        filename: 'identity_doc.jpg',
      ),
      'workLocation': workLocation,
      'experience': experience,
      if (description != null && description.isNotEmpty)
        'description': description,
    });

    final response = await _dio.post<dynamic>(
      '/walkers/apply',
      data: formData,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return WalkerProfileDto.fromApplyResponse(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerProfileFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerProfileFailure(
      'APPLY_FAILED',
      'Unexpected response ($status).',
    );
  }

  /// PUT /walkers/me — update approved walker profile.
  Future<WalkerProfileDto> updateMyProfile({
    String? bio,
    double? hourlyRate,
    double? serviceRadiusKm,
    int? yearsOfExperience,
    bool? isAcceptingBookings,
    double? workLatitude,
    double? workLongitude,
  }) async {
    final body = <String, dynamic>{};
    if (bio != null) body['bio'] = bio;
    if (hourlyRate != null) body['hourlyRate'] = hourlyRate;
    if (serviceRadiusKm != null) body['serviceRadiusKm'] = serviceRadiusKm;
    if (yearsOfExperience != null) {
      body['yearsOfExperience'] = yearsOfExperience;
    }
    if (isAcceptingBookings != null) {
      body['isAcceptingBookings'] = isAcceptingBookings;
    }
    if (workLatitude != null) body['workLatitude'] = workLatitude;
    if (workLongitude != null) body['workLongitude'] = workLongitude;

    final response = await _dio.put<dynamic>('/walkers/me', data: body);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return WalkerProfileDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerProfileFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerProfileFailure(
      'UPDATE_FAILED',
      'Unexpected response ($status).',
    );
  }

  /// POST /walkers/ — register current user as a walker (basic registration).
  Future<WalkerProfileDto> becomeWalker() async {
    final response = await _dio.post<dynamic>('/walkers/');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return WalkerProfileDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerProfileFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerProfileFailure(
      'BECOME_WALKER_FAILED',
      'Unexpected response ($status).',
    );
  }
}
