import 'package:dio/dio.dart';

import '../../domain/repositories/walker_availability_repository.dart';
import '../models/availability_exception_dto.dart';
import '../models/availability_slot_dto.dart';

class WalkerAvailabilityRemoteDataSource {
  WalkerAvailabilityRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<AvailabilitySlotDto>> getMyAvailability() async {
    final response = await _dio.get<dynamic>('/walkers/me/availability');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailabilitySlotDto.fromJsonList(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerAvailabilityFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerAvailabilityFailure(
      'FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<List<AvailabilitySlotDto>> replaceMyAvailability(
    List<AvailabilitySlotDto> slots,
  ) async {
    final body = slots.map((s) => s.toJson()).toList();

    final response = await _dio.put<dynamic>(
      '/walkers/me/availability',
      data: body,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailabilitySlotDto.fromJsonList(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerAvailabilityFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerAvailabilityFailure(
      'REPLACE_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<List<AvailabilityExceptionDto>> getMyExceptions() async {
    final response = await _dio.get<dynamic>('/walkers/me/availability/exceptions');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailabilityExceptionDto.fromJsonList(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerAvailabilityFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerAvailabilityFailure(
      'FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<List<AvailabilityExceptionDto>> replaceMyExceptions(
    List<AvailabilityExceptionDto> exceptions,
  ) async {
    final body = exceptions.map((e) => e.toJson()).toList();

    final response = await _dio.put<dynamic>(
      '/walkers/me/availability/exceptions',
      data: body,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailabilityExceptionDto.fromJsonList(data);
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkerAvailabilityFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw WalkerAvailabilityFailure(
      'REPLACE_FAILED',
      'Unexpected response ($status).',
    );
  }
}
