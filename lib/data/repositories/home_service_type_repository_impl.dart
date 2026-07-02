import 'package:dio/dio.dart';

import '../../domain/entities/home_service_type.dart';
import '../../domain/repositories/home_service_type_repository.dart';
import '../datasources/home_service_type_remote_datasource.dart';

class HomeServiceTypeRepositoryImpl implements HomeServiceTypeRepository {
  HomeServiceTypeRepositoryImpl(this._remote);

  final HomeServiceTypeRemoteDataSource _remote;

  @override
  Future<List<HomeServiceType>> getTypes() async {
    try {
      final dtos = await _remote.getTypes();
      return dtos.map((dto) => dto.toEntity()).toList();
    } on HomeServiceTypeFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceTypeFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
