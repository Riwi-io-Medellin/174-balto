import 'package:dio/dio.dart';

import '../../domain/entities/available_slot.dart';
import '../../domain/repositories/walker_repository.dart';
import '../models/available_slot_dto.dart';
import '../models/walker_dto.dart';

class WalkerRemoteDataSource {
  WalkerRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /walkers/ — list all walkers with optional filters.
  Future<List<WalkerListDto>> getWalkers({
    bool? available,
    String? workLocation,
  }) async {
    final queryParams = <String, dynamic>{};
    if (available != null) queryParams['available'] = available;
    if (workLocation != null) queryParams['workLocation'] = workLocation;

    final response =
        await _dio.get<dynamic>('/walkers/', queryParameters: queryParams);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map((e) => WalkerListDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerFailure('FETCH_FAILED', 'Unexpected response ($status).');
  }

  /// GET /walkers/search — search approved walkers by location/date/duration.
  Future<WalkerSearchResultDto> searchWalkers({
    required double latitude,
    required double longitude,
    required double radiusKm,
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
    };

    final response =
        await _dio.get<dynamic>('/walkers/search', queryParameters: queryParams);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return WalkerSearchResultDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerFailure('SEARCH_FAILED', 'Unexpected response ($status).');
  }

  /// GET /walkers/{id} — full walker detail.
  Future<WalkerDetailDto> getWalkerDetail(
    String walkerId, {
    String? date,
    int? durationMinutes,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date;
    if (durationMinutes != null) {
      queryParams['durationMinutes'] = durationMinutes;
    }

    final response = await _dio.get<dynamic>(
      '/walkers/$walkerId',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return WalkerDetailDto.fromJson(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerFailure('DETAIL_FAILED', 'Unexpected response ($status).');
  }

  /// GET /walkers/{walkerId}/available-slots — computed booking slots for a date.
  Future<List<AvailableSlot>> getAvailableSlots({
    required String walkerId,
    required String date,
    required int durationMinutes,
  }) async {
    final response = await _dio.get<dynamic>(
      '/walkers/$walkerId/available-slots',
      queryParameters: {'date': date, 'durationMinutes': durationMinutes},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailableSlotDto.listToEntities(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerFailure(data['code'] as String, data['error'] as String);
    }

    throw WalkerFailure('SLOTS_FAILED', 'Unexpected response ($status).');
  }
}

/// Wraps the paged search result from the backend.
class WalkerSearchResultDto {
  WalkerSearchResultDto({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  factory WalkerSearchResultDto.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List)
        .map((e) => WalkerSummaryDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return WalkerSearchResultDto(
      items: itemsList,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalCount: json['totalCount'] as int,
    );
  }

  final List<WalkerSummaryDto> items;
  final int page;
  final int pageSize;
  final int totalCount;
}
