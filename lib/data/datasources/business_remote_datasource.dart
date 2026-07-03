import 'package:dio/dio.dart';

import '../../domain/repositories/business_repository.dart';
import '../models/business_dto.dart';

class BusinessRemoteDataSource {
  BusinessRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /businesses — list all businesses with optional filters.
  Future<List<BusinessDto>> getBusinesses({
    String? type,
    String? location,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;
    if (location != null) queryParams['location'] = location;

    final response = await _dio.get<dynamic>(
      '/businesses',
      queryParameters: queryParams,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map((e) => BusinessDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure('FETCH_FAILED', 'Unexpected response ($status).');
  }

  /// GET /businesses/{id} — full business detail.
  Future<BusinessDto> getBusinessDetail(String businessId) async {
    final response = await _dio.get<dynamic>('/businesses/$businessId');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return BusinessDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure('DETAIL_FAILED', 'Unexpected response ($status).');
  }

  /// POST /businesses — register a new business for the current user.
  Future<BusinessDto> createBusiness({
    required String name,
    required String nit,
    required String email,
    required String phone,
    String? type,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'nit': nit,
      'email': email,
      'phone': int.tryParse(phone) ?? phone,
      if (type != null) 'type': type,
      if (location != null) 'location': location,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response = await _dio.post<dynamic>('/businesses', data: body);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return BusinessDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure('CREATE_FAILED', 'Unexpected response ($status).');
  }

  /// GET /businesses/me — the current user's own business, if any.
  /// Returns null on 404 (user has never registered a business).
  Future<BusinessDto?> getMyBusiness() async {
    final response = await _dio.get<dynamic>(
      '/businesses/me',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return BusinessDto.fromJson(data);
    }
    if (status == 404) return null;

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure('MY_BUSINESS_FAILED', 'Unexpected response ($status).');
  }

  /// PUT /businesses/me — update the current user's approved business.
  Future<BusinessDto> updateMyBusiness({
    String? instagramUrl,
    String? facebookUrl,
  }) async {
    final body = <String, dynamic>{
      if (instagramUrl != null) 'instagramUrl': instagramUrl,
      if (facebookUrl != null) 'facebookUrl': facebookUrl,
    };

    final response = await _dio.put<dynamic>('/businesses/me', data: body);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return BusinessDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure('UPDATE_FAILED', 'Unexpected response ($status).');
  }

  /// GET /businesses/{id}/hours — public weekly schedule.
  Future<List<BusinessHourDto>> getBusinessHours(String businessId) async {
    final response = await _dio.get<dynamic>('/businesses/$businessId/hours');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return BusinessHourDto.fromJsonList(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure('HOURS_FAILED', 'Unexpected response ($status).');
  }

  /// GET /businesses/{id}/hours/exceptions — public date-specific overrides.
  Future<List<BusinessHourExceptionDto>> getBusinessHourExceptions(
    String businessId,
  ) async {
    final response =
        await _dio.get<dynamic>('/businesses/$businessId/hours/exceptions');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return BusinessHourExceptionDto.fromJsonList(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure(
      'HOUR_EXCEPTIONS_FAILED',
      'Unexpected response ($status).',
    );
  }

  /// PUT /businesses/me/hours — replace the current user's weekly schedule.
  Future<List<BusinessHourDto>> updateMyHours(
    List<Map<String, dynamic>> hours,
  ) async {
    final response = await _dio.put<dynamic>(
      '/businesses/me/hours',
      data: hours,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return BusinessHourDto.fromJsonList(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure(
      'HOURS_UPDATE_FAILED',
      'Unexpected response ($status).',
    );
  }

  /// POST /businesses/{id}/documents — attach a NIT/verification document.
  /// The file must already be hosted (upload it first via UploadRepository
  /// to get [fileUrl]); this endpoint only registers the URL.
  Future<void> addBusinessDocument({
    required String businessId,
    required String documentType,
    required String fileUrl,
  }) async {
    final response = await _dio.post<dynamic>(
      '/businesses/$businessId/documents',
      data: {'documentType': documentType, 'fileUrl': fileUrl},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 || status == 201) return;

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure(
      'DOCUMENT_UPLOAD_FAILED',
      'Unexpected response ($status).',
    );
  }

  /// GET /businesses/{id}/services — real services list for the profile tabs.
  Future<List<BusinessServiceItemDto>> getBusinessServices(
    String businessId,
  ) async {
    final response =
        await _dio.get<dynamic>('/businesses/$businessId/services');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map((e) =>
              BusinessServiceItemDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw BusinessFailure(data['code'] as String, data['error'] as String);
    }

    throw BusinessFailure('SERVICES_FAILED', 'Unexpected response ($status).');
  }
}
