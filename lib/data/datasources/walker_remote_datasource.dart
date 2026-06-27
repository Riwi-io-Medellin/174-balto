import 'package:dio/dio.dart';

import '../../domain/repositories/walker_repository.dart';
import '../models/walker_dto.dart';

class WalkerRemoteDataSource {
  WalkerRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<WalkerDto>> getAll() async {
    final response = await _dio.get<dynamic>('/walkers/');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(WalkerDto.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerFailure(data['code'] as String, data['error'] as String);
    }

    throw WalkerFailure(
      'WALKERS_FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }
}
