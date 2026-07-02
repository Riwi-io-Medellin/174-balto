import 'package:dio/dio.dart';

import '../../domain/entities/home_provider_service_item.dart';
import '../../domain/repositories/home_provider_services_repository.dart';
import '../datasources/home_provider_services_remote_datasource.dart';

class HomeProviderServicesRepositoryImpl
    implements HomeProviderServicesRepository {
  HomeProviderServicesRepositoryImpl(this._remote);

  final HomeProviderServicesRemoteDataSource _remote;

  @override
  Future<List<HomeProviderServiceItem>> getByProviderId(
      String providerId) async {
    try {
      final dtos = await _remote.getByProviderId(providerId);
      return dtos.map((dto) => dto.toEntity()).toList();
    } on HomeProviderServicesFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderServicesFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<HomeProviderServiceItem> addMyService({
    required String serviceTypeId,
    double? price,
    required String priceUnit,
    String? description,
  }) async {
    try {
      final dto = await _remote.addMyService(
        serviceTypeId: serviceTypeId,
        price: price,
        priceUnit: priceUnit,
        description: description,
      );
      return dto.toEntity();
    } on HomeProviderServicesFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderServicesFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<HomeProviderServiceItem> updateMyService({
    required String serviceId,
    double? price,
    required String priceUnit,
    String? description,
    required bool isActive,
  }) async {
    try {
      final dto = await _remote.updateMyService(
        serviceId: serviceId,
        price: price,
        priceUnit: priceUnit,
        description: description,
        isActive: isActive,
      );
      return dto.toEntity();
    } on HomeProviderServicesFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderServicesFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> deleteMyService(String serviceId) async {
    try {
      await _remote.deleteMyService(serviceId);
    } on HomeProviderServicesFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderServicesFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
