import 'package:dio/dio.dart';

import '../../domain/repositories/home_service_availability_repository.dart';
import '../models/availability_exception_dto.dart';
import '../models/availability_slot_dto.dart';

class HomeServiceAvailabilityRemoteDataSource {
  HomeServiceAvailabilityRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<AvailabilitySlotDto>> getMyAvailability() async {
    final response =
        await _dio.get<dynamic>('/home-services/providers/me/availability');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailabilitySlotDto.fromJsonList(data);
    }
    _throwFailure(status, data, 'FETCH_FAILED');
  }

  Future<List<AvailabilitySlotDto>> replaceMyAvailability(
    List<AvailabilitySlotDto> slots,
  ) async {
    final body = slots.map((s) => s.toJson()).toList();

    final response = await _dio.put<dynamic>(
      '/home-services/providers/me/availability',
      data: body,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailabilitySlotDto.fromJsonList(data);
    }
    _throwFailure(status, data, 'REPLACE_FAILED');
  }

  Future<List<AvailabilityExceptionDto>> getMyExceptions() async {
    final response = await _dio.get<dynamic>(
      '/home-services/providers/me/availability/exceptions',
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailabilityExceptionDto.fromJsonList(data);
    }
    _throwFailure(status, data, 'FETCH_FAILED');
  }

  Future<List<AvailabilityExceptionDto>> replaceMyExceptions(
    List<AvailabilityExceptionDto> exceptions,
  ) async {
    final body = exceptions.map((e) => e.toJson()).toList();

    final response = await _dio.put<dynamic>(
      '/home-services/providers/me/availability/exceptions',
      data: body,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return AvailabilityExceptionDto.fromJsonList(data);
    }
    _throwFailure(status, data, 'REPLACE_FAILED');
  }

  Never _throwFailure(int status, dynamic data, String fallbackCode) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeServiceAvailabilityFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw HomeServiceAvailabilityFailure(
      fallbackCode,
      'Unexpected response ($status).',
    );
  }
}
