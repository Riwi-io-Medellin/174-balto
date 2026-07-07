import 'package:dio/dio.dart';

import '../../domain/entities/available_slot.dart';
import '../../domain/entities/home_service_provider.dart';
import '../../domain/repositories/home_service_provider_repository.dart';
import '../datasources/home_service_remote_datasource.dart';

class HomeServiceProviderRepositoryImpl
    implements HomeServiceProviderRepository {
  HomeServiceProviderRepositoryImpl(this._remote);

  final HomeServiceRemoteDataSource _remote;

  @override
  Future<List<HomeServiceProvider>> getProviders({
    bool? isAcceptingBookings,
    String? baseLocation,
  }) async {
    try {
      final result = await _remote.getProviders(
        isAcceptingBookings: isAcceptingBookings,
        baseLocation: baseLocation,
      );
      return result.map((dto) => dto.toEntity()).toList();
    } on HomeServiceFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<HomeServiceSearchResult> searchProviders({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? serviceTypeId,
    required String date,
    required int durationMinutes,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remote.searchProviders(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        serviceTypeId: serviceTypeId,
        date: date,
        durationMinutes: durationMinutes,
        page: page,
        pageSize: pageSize,
      );
      return HomeServiceSearchResult(
        items: result.items.map((dto) => dto.toEntity()).toList(),
        page: result.page,
        pageSize: result.pageSize,
        totalCount: result.totalCount,
      );
    } on HomeServiceFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<HomeServiceProvider> getProviderDetail(
    String providerId, {
    String? date,
    int? durationMinutes,
  }) async {
    try {
      final dto = await _remote.getProviderDetail(
        providerId,
        date: date,
        durationMinutes: durationMinutes,
      );
      return dto.toEntity();
    } on HomeServiceFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<AvailableSlot>> getAvailableSlots({
    required String providerId,
    required String date,
    required int durationMinutes,
  }) async {
    try {
      return await _remote.getAvailableSlots(
        providerId: providerId,
        date: date,
        durationMinutes: durationMinutes,
      );
    } on HomeServiceFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
