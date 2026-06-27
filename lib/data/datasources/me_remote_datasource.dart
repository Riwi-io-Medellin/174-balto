import 'package:dio/dio.dart';

import '../../domain/repositories/me_repository.dart';
import '../models/me_dto.dart';

class MeRemoteDataSource {
  MeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<MeDto> get() async {
    final response = await _dio.get<dynamic>('/me');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return MeDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw MeFailure(data['code'] as String, data['error'] as String);
    }

    throw MeFailure('ME_FETCH_FAILED', 'Unexpected response ($status).');
  }
}
