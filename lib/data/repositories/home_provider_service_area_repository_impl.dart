import 'package:dio/dio.dart';

import '../../domain/entities/home_provider_service_area.dart';
import '../../domain/repositories/home_provider_service_area_repository.dart';
import '../datasources/home_provider_service_area_remote_datasource.dart';
import '../models/home_provider_service_area_dto.dart';

class HomeProviderServiceAreaRepositoryImpl
    implements HomeProviderServiceAreaRepository {
  HomeProviderServiceAreaRepositoryImpl(this._remote);

  final HomeProviderServiceAreaRemoteDataSource _remote;

  @override
  Future<List<HomeProviderServiceArea>> getMyServiceAreas() async {
    try {
      final dtos = await _remote.getMyServiceAreas();
      return dtos.map((d) => d.toEntity()).toList();
    } on HomeProviderServiceAreaFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderServiceAreaFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<HomeProviderServiceArea>> replaceMyServiceAreas(
    List<HomeProviderServiceArea> areas,
  ) async {
    try {
      final dtos = areas
          .map((a) => HomeProviderServiceAreaDto(
                id: a.id,
                label: a.label,
                latitude: a.latitude,
                longitude: a.longitude,
                radiusKm: a.radiusKm,
              ))
          .toList();
      final result = await _remote.replaceMyServiceAreas(dtos);
      return result.map((d) => d.toEntity()).toList();
    } on HomeProviderServiceAreaFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderServiceAreaFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
