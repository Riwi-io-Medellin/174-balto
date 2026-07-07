import 'package:dio/dio.dart';

import '../../domain/repositories/home_service_booking_repository.dart';
import '../models/home_service_booking_dto.dart';

class HomeServiceBookingRemoteDataSource {
  HomeServiceBookingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<HomeServiceBookingResponseDto> createBooking({
    required String providerId,
    required String serviceTypeId,
    required String petId,
    required String slotStart,
    required int durationMinutes,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
  }) async {
    final body = <String, dynamic>{
      'providerId': providerId,
      'serviceTypeId': serviceTypeId,
      'petId': petId,
      'slotStart': slotStart,
      'durationMinutes': durationMinutes,
      if (serviceAddress != null && serviceAddress.isNotEmpty)
        'serviceAddress': serviceAddress,
      'serviceLatitude': ?serviceLatitude,
      'serviceLongitude': ?serviceLongitude,
      if (specialInstructions != null && specialInstructions.isNotEmpty)
        'specialInstructions': specialInstructions,
    };

    final response = await _dio.post<dynamic>(
      '/home-service-bookings',
      data: body,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return HomeServiceBookingResponseDto.fromJson(data);
    }
    _throwFailure(status, data);
  }

  Future<List<HomeServiceBookingResponseDto>> getMyBookings({
    String? status,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response = await _dio.get<dynamic>(
      '/home-service-bookings/me',
      queryParameters: params,
    );
    final code = response.statusCode ?? 0;
    final data = response.data;

    if (code == 200 && data is Map<String, dynamic>) {
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map(
            (e) => HomeServiceBookingResponseDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    _throwFailure(code, data);
  }

  Future<void> clientCancelBooking(String bookingId) async {
    final response = await _dio.post<dynamic>(
      '/home-service-bookings/$bookingId/client-cancel',
    );
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Future<List<HomeServiceBookingResponseDto>> getProviderBookings({
    String? status,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response = await _dio.get<dynamic>(
      '/home-services/providers/me/bookings',
      queryParameters: params.isEmpty ? null : params,
    );
    final code = response.statusCode ?? 0;
    final data = response.data;

    if (code == 200 && data is Map<String, dynamic>) {
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map(
            (e) => HomeServiceBookingResponseDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    _throwFailure(code, data);
  }

  Future<void> acceptBooking(String bookingId) async {
    final response = await _dio.post<dynamic>(
      '/home-service-bookings/$bookingId/accept',
    );
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Future<void> rejectBooking(String bookingId) async {
    final response = await _dio.post<dynamic>(
      '/home-service-bookings/$bookingId/reject',
    );
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Future<void> providerCancelBooking(String bookingId) async {
    final response = await _dio.post<dynamic>(
      '/home-service-bookings/$bookingId/cancel',
    );
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Future<void> startSession(String bookingId) async {
    final response = await _dio.post<dynamic>(
      '/home-service-sessions/from-booking/$bookingId',
    );
    final status = response.statusCode ?? 0;
    if (status == 200 || status == 201) return;
    _throwFailure(status, response.data);
  }

  Future<void> finishSession(String sessionId) async {
    final response = await _dio.post<dynamic>(
      '/home-service-sessions/$sessionId/finish',
      data: {'totalDurationSeconds': 0},
    );
    final status = response.statusCode ?? 0;
    if (status == 200) return;
    _throwFailure(status, response.data);
  }

  Never _throwFailure(int status, dynamic data) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeServiceBookingFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw HomeServiceBookingFailure(
      'REQUEST_FAILED',
      'Unexpected response ($status).',
    );
  }
}
