import 'package:dio/dio.dart';

import '../../domain/entities/available_slot.dart';
import '../../domain/repositories/home_service_provider_repository.dart';
import '../models/available_slot_dto.dart';
import '../models/home_service_provider_dto.dart';

class HomeServiceRemoteDataSource {
  HomeServiceRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /home-services/providers — list all providers with optional filters.
  Future<List<HomeServiceProviderListDto>> getProviders({
    bool? isAcceptingBookings,
    String? baseLocation,
  }) async {
    final queryParams = <String, dynamic>{};
    if (isAcceptingBookings != null) {
      queryParams['isAcceptingBookings'] = isAcceptingBookings;
    }
    if (baseLocation != null) queryParams['baseLocation'] = baseLocation;

    final response = await _dio.get<dynamic>(
      '/home-services/providers',
      queryParameters: queryParams,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map(
            (e) =>
                HomeServiceProviderListDto.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }

    _throwFailure(status, data, 'FETCH_FAILED');
  }

  /// GET /home-services/providers/search — search approved providers.
  Future<HomeServiceSearchResultDto> searchProviders({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? serviceTypeId,
    required String date,
    required int durationMinutes,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
      'date': date,
      'durationMinutes': durationMinutes,
      'page': page,
      'pageSize': pageSize,
      'serviceTypeId': ?serviceTypeId,
    };

    final response = await _dio.get<dynamic>(
      '/home-services/providers/search',
      queryParameters: queryParams,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return HomeServiceSearchResultDto.fromJson(data);
    }

    _throwFailure(status, data, 'SEARCH_FAILED');
  }

  /// GET /home-services/providers/{id} — full provider detail.
  Future<HomeServiceProviderDetailDto> getProviderDetail(
    String providerId, {
    String? date,
    int? durationMinutes,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date;
    if (durationMinutes != null) {
      queryParams['durationMinutes'] = durationMinutes;
    }

    final response = await _dio.get<dynamic>(
      '/home-services/providers/$providerId',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return HomeServiceProviderDetailDto.fromJson(data);
    }

    _throwFailure(status, data, 'DETAIL_FAILED');
  }

  /// GET /home-services/providers/{id}/available-slots
  Future<List<AvailableSlot>> getAvailableSlots({
    required String providerId,
    required String date,
    required int durationMinutes,
  }) async {
    final response = await _dio.get<dynamic>(
      '/home-services/providers/$providerId/available-slots',
      queryParameters: {'date': date, 'durationMinutes': durationMinutes},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailableSlotDto.listToEntities(data);
    }

    _throwFailure(status, data, 'SLOTS_FAILED');
  }

  Never _throwFailure(int status, dynamic data, String fallbackCode) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeServiceFailure(data['code'] as String, data['error'] as String);
    }
    throw HomeServiceFailure(fallbackCode, 'Unexpected response ($status).');
  }
}

/// Wraps the paged search result from the backend.
class HomeServiceSearchResultDto {
  HomeServiceSearchResultDto({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  factory HomeServiceSearchResultDto.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List)
        .map(
          (e) =>
              HomeServiceProviderSummaryDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    return HomeServiceSearchResultDto(
      items: itemsList,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalCount: json['totalCount'] as int,
    );
  }

  final List<HomeServiceProviderSummaryDto> items;
  final int page;
  final int pageSize;
  final int totalCount;
}
