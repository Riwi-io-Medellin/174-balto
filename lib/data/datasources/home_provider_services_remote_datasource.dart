import 'package:dio/dio.dart';

import '../../domain/repositories/home_provider_services_repository.dart';
import '../models/home_provider_service_dto.dart';

class HomeProviderServicesRemoteDataSource {
  HomeProviderServicesRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /home-services/providers/{id}/services
  Future<List<HomeProviderServiceDto>> getByProviderId(
      String providerId) async {
    final response = await _dio
        .get<dynamic>('/home-services/providers/$providerId/services');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map((e) =>
              HomeProviderServiceDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _throwFailure(status, data, 'FETCH_FAILED');
  }

  /// POST /home-services/providers/me/services
  Future<HomeProviderServiceDto> addMyService({
    required String serviceTypeId,
    double? price,
    required String priceUnit,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'serviceTypeId': serviceTypeId,
      'price': price,
      'priceUnit': priceUnit,
      if (description != null && description.isNotEmpty)
        'description': description,
    };

    final response = await _dio.post<dynamic>(
      '/home-services/providers/me/services',
      data: body,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return HomeProviderServiceDto.fromJson(data);
    }

    _throwFailure(status, data, 'ADD_FAILED');
  }

  /// PUT /home-services/providers/me/services/{id}
  Future<HomeProviderServiceDto> updateMyService({
    required String serviceId,
    double? price,
    required String priceUnit,
    String? description,
    required bool isActive,
  }) async {
    final body = <String, dynamic>{
      'price': price,
      'priceUnit': priceUnit,
      'description': description,
      'isActive': isActive,
    };

    final response = await _dio.put<dynamic>(
      '/home-services/providers/me/services/$serviceId',
      data: body,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return HomeProviderServiceDto.fromJson(data);
    }

    _throwFailure(status, data, 'UPDATE_FAILED');
  }

  /// DELETE /home-services/providers/me/services/{id}
  Future<void> deleteMyService(String serviceId) async {
    final response = await _dio.delete<dynamic>(
      '/home-services/providers/me/services/$serviceId',
    );
    final status = response.statusCode ?? 0;
    if (status == 204 || status == 200) return;
    _throwFailure(status, response.data, 'DELETE_FAILED');
  }

  Never _throwFailure(int status, dynamic data, String fallbackCode) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeProviderServicesFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw HomeProviderServicesFailure(
      fallbackCode,
      'Unexpected response ($status).',
    );
  }
}
