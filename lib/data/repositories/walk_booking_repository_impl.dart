import 'package:dio/dio.dart';

import '../../domain/entities/walk_booking.dart';
import '../../domain/repositories/walk_booking_repository.dart';
import '../datasources/walk_booking_remote_datasource.dart';

class WalkBookingRepositoryImpl implements WalkBookingRepository {
  WalkBookingRepositoryImpl(this._remote);

  final WalkBookingRemoteDataSource _remote;

  @override
  Future<WalkBooking> createBooking({
    required String walkerId,
    required String petId,
    required DateTime slotStart,
    required int durationMinutes,
    String? specialInstructions,
    bool isExclusive = false,
  }) async {
    try {
      final dto = await _remote.createBooking(
        walkerId: walkerId,
        petId: petId,
        slotStart: slotStart.toIso8601String(),
        durationMinutes: durationMinutes,
        specialInstructions: specialInstructions,
        isExclusive: isExclusive,
      );
      return dto.toEntity();
    } on WalkBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<WalkBooking>> getMyBookings({String? status}) async {
    try {
      final dtos = await _remote.getMyBookings(status: status);
      return dtos.map((d) => d.toEntity()).toList();
    } on WalkBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _remote.cancelBooking(bookingId);
    } on WalkBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<WalkBooking>> getWalkerBookings({String? status}) async {
    try {
      final dtos = await _remote.getWalkerBookings(status: status);
      return dtos.map((d) => d.toEntity()).toList();
    } on WalkBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    try {
      await _remote.acceptBooking(bookingId);
    } on WalkBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> rejectBooking(String bookingId) async {
    try {
      await _remote.rejectBooking(bookingId);
    } on WalkBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> walkerCancelBooking(String bookingId) async {
    try {
      await _remote.walkerCancelBooking(bookingId);
    } on WalkBookingFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkBookingFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

}
