import 'package:dio/dio.dart';

import '../../domain/repositories/home_service_profile_repository.dart';
import '../models/home_service_provider_profile_dto.dart';

class HomeServiceProfileRemoteDataSource {
  HomeServiceProfileRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /home-services/providers/me — null when the user has no profile (404).
  Future<HomeServiceProviderProfileDto?> getMe() async {
    final response = await _dio.get<dynamic>('/home-services/providers/me');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 404) return null;

    if (status == 200 && data is Map<String, dynamic>) {
      return HomeServiceProviderProfileDto.fromJson(data);
    }

    _throwFailure(status, data, 'FETCH_FAILED');
  }

  /// POST /home-services/providers — basic registration, no document.
  Future<HomeServiceProviderProfileDto> becomeProvider() async {
    final response = await _dio.post<dynamic>('/home-services/providers');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return HomeServiceProviderProfileDto.fromJson(data);
    }

    _throwFailure(status, data, 'BECOME_PROVIDER_FAILED');
  }

  /// POST /home-services/providers/apply — multipart upload with document + profile info.
  Future<HomeServiceProviderProfileDto> apply({
    required String filePath,
    required String baseLocation,
    required String experience,
    String? description,
  }) async {
    final formData = FormData.fromMap({
      'document': await MultipartFile.fromFile(
        filePath,
        filename: 'identity_doc.jpg',
      ),
      'baseLocation': baseLocation,
      'experience': experience,
      if (description != null && description.isNotEmpty)
        'description': description,
    });

    final response = await _dio.post<dynamic>(
      '/home-services/providers/apply',
      data: formData,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return HomeServiceProviderProfileDto.fromApplyResponse(data);
    }

    _throwFailure(status, data, 'APPLY_FAILED');
  }

  /// PUT /home-services/providers/me — update approved provider profile.
  Future<HomeServiceProviderProfileDto> updateMyProfile({
    String? bio,
    int? yearsOfExperience,
    bool? isAcceptingBookings,
    int? maxConcurrentBookings,
    String? baseLocation,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{};
    if (bio != null) body['bio'] = bio;
    if (yearsOfExperience != null) {
      body['yearsOfExperience'] = yearsOfExperience;
    }
    if (isAcceptingBookings != null) {
      body['isAcceptingBookings'] = isAcceptingBookings;
    }
    if (maxConcurrentBookings != null) {
      body['maxConcurrentBookings'] = maxConcurrentBookings;
    }
    if (baseLocation != null) body['baseLocation'] = baseLocation;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;

    final response =
        await _dio.put<dynamic>('/home-services/providers/me', data: body);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return HomeServiceProviderProfileDto.fromJson(data);
    }

    _throwFailure(status, data, 'UPDATE_FAILED');
  }

  Never _throwFailure(int status, dynamic data, String fallbackCode) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeServiceProfileFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw HomeServiceProfileFailure(
      fallbackCode,
      'Unexpected response ($status).',
    );
  }
}
