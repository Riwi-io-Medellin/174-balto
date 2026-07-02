import 'package:dio/dio.dart';

import '../../domain/entities/home_service_booking.dart';
import '../../domain/repositories/home_service_booking_repository.dart';
import '../datasources/home_service_booking_remote_datasource.dart';

class HomeServiceBookingRepositoryImpl implements HomeServiceBookingRepository {
  HomeServiceBookingRepositoryImpl(this._remote);

  final HomeServiceBookingRemoteDataSource _remote;

  @override
  Future<HomeServiceBooking> createBooking({
    required String providerId,
    required String serviceTypeId,
    required String petId,
    required DateTime slotStart,
    required int durationMinutes,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
  }) async {
    try {
      final dto = await _remote.createBooking(
        providerId: providerId,
        serviceTypeId: serviceTypeId,
        petId: petId,
        slotStart: slotStart.toIso8601String(),
        durationMinutes: durationMinutes,
        serviceAddress: serviceAddress,
        serviceLatitude: serviceLatitude,
        serviceLongitude: serviceLongitude,
        specialInstructions: specialInstructions,
      );
      return dto.toEntity();
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<HomeServiceBooking>> getMyBookings({String? status}) async {
    try {
      final dtos = await _remote.getMyBookings(status: status);
      return dtos.map((d) => d.toEntity()).toList();
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> clientCancelBooking(String bookingId) async {
    try {
      await _remote.clientCancelBooking(bookingId);
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<HomeServiceBooking>> getProviderBookings({String? status}) async {
    try {
      final dtos = await _remote.getProviderBookings(status: status);
      return dtos.map((d) => d.toEntity()).toList();
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    try {
      await _remote.acceptBooking(bookingId);
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> rejectBooking(String bookingId) async {
    try {
      await _remote.rejectBooking(bookingId);
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> providerCancelBooking(String bookingId) async {
    try {
      await _remote.providerCancelBooking(bookingId);
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> startSession(String bookingId) async {
    try {
      await _remote.startSession(bookingId);
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> finishSession(String sessionId) async {
    try {
      await _remote.finishSession(sessionId);
    } on HomeServiceBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
