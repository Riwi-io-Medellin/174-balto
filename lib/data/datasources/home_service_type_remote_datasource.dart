import 'package:dio/dio.dart';

import '../../domain/repositories/home_service_type_repository.dart';
import '../models/home_service_type_dto.dart';

class HomeServiceTypeRemoteDataSource {
  HomeServiceTypeRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /home-services/types
  Future<List<HomeServiceTypeDto>> getTypes() async {
    final response = await _dio.get<dynamic>('/home-services/types');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map((e) => HomeServiceTypeDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeServiceTypeFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw HomeServiceTypeFailure(
      'FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }
}
