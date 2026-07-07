import 'package:dio/dio.dart';

import '../../domain/repositories/home_provider_service_area_repository.dart';
import '../models/home_provider_service_area_dto.dart';

class HomeProviderServiceAreaRemoteDataSource {
  HomeProviderServiceAreaRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<HomeProviderServiceAreaDto>> getMyServiceAreas() async {
    final response = await _dio.get<dynamic>(
      '/home-services/providers/me/service-areas',
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return HomeProviderServiceAreaDto.fromJsonList(data);
    }
    _throwFailure(status, data, 'FETCH_FAILED');
  }

  Future<List<HomeProviderServiceAreaDto>> replaceMyServiceAreas(
    List<HomeProviderServiceAreaDto> areas,
  ) async {
    final body = areas.map((a) => a.toJson()).toList();

    final response = await _dio.put<dynamic>(
      '/home-services/providers/me/service-areas',
      data: body,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return HomeProviderServiceAreaDto.fromJsonList(data);
    }
    _throwFailure(status, data, 'REPLACE_FAILED');
  }

  Never _throwFailure(int status, dynamic data, String fallbackCode) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeProviderServiceAreaFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw HomeProviderServiceAreaFailure(
      fallbackCode,
      'Unexpected response ($status).',
    );
  }
}
