import 'package:dio/dio.dart';

import '../../domain/repositories/walk_booking_repository.dart';
import '../models/walk_booking_dto.dart';

class WalkBookingRemoteDataSource {
  WalkBookingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<BookingResponseDto> createBooking({
    required String walkerId,
    required String petId,
    required String slotStart,
    required int durationMinutes,
    String? specialInstructions,
  }) async {
    final body = <String, dynamic>{
      'walkerId': walkerId,
      'petId': petId,
      'slotStart': slotStart,
      'durationMinutes': durationMinutes,
      if (specialInstructions != null && specialInstructions.isNotEmpty)
        'specialInstructions': specialInstructions,
    };

    final response = await _dio.post<dynamic>('/walk-bookings/', data: body);
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return BookingResponseDto.fromJson(data);
    }

    _throwFailure(status, data);
  }

  Future<List<BookingResponseDto>> getMyBookings({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response =
        await _dio.get<dynamic>('/walk-bookings/me', queryParameters: params);
    final code = response.statusCode ?? 0;
    final data = response.data;

    if (code == 200 && data is Map<String, dynamic>) {
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map((e) => BookingResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _throwFailure(code, data);
  }

  Future<void> cancelBooking(String bookingId) async {
    final response =
        await _dio.post<dynamic>('/walk-bookings/$bookingId/owner-cancel');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200) return;

    _throwFailure(status, data);
  }

  Future<List<BookingResponseDto>> getWalkerBookings({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response = await _dio.get<dynamic>(
      '/walkers/me/bookings',
      queryParameters: params.isEmpty ? null : params,
    );
    final code = response.statusCode ?? 0;
    final data = response.data;

    if (code == 200 && data is Map<String, dynamic>) {
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map((e) => BookingResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _throwFailure(code, data);
  }

  Future<void> acceptBooking(String bookingId) async {
    final response =
        await _dio.post<dynamic>('/walk-bookings/$bookingId/accept');
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Future<void> rejectBooking(String bookingId) async {
    final response =
        await _dio.post<dynamic>('/walk-bookings/$bookingId/reject');
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Future<void> walkerCancelBooking(String bookingId) async {
    final response =
        await _dio.post<dynamic>('/walk-bookings/$bookingId/cancel');
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Never _throwFailure(int status, dynamic data) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw WalkBookingFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw WalkBookingFailure('REQUEST_FAILED', 'Unexpected response ($status).');
  }
}
