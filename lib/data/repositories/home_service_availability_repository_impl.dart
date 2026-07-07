import 'package:dio/dio.dart';

import '../../domain/entities/availability_exception.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/repositories/home_service_availability_repository.dart';
import '../datasources/home_service_availability_remote_datasource.dart';
import '../models/availability_exception_dto.dart';
import '../models/availability_slot_dto.dart';

class HomeServiceAvailabilityRepositoryImpl
    implements HomeServiceAvailabilityRepository {
  HomeServiceAvailabilityRepositoryImpl(this._remote);

  final HomeServiceAvailabilityRemoteDataSource _remote;

  @override
  Future<List<AvailabilitySlot>> getMyAvailability() async {
    try {
      final dtos = await _remote.getMyAvailability();
      return dtos.map((dto) => dto.toEntity()).toList();
    } on HomeServiceAvailabilityFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceAvailabilityFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<AvailabilitySlot>> replaceMyAvailability(
    List<AvailabilitySlot> slots,
  ) async {
    try {
      final dtos = slots
          .map(
            (s) => AvailabilitySlotDto(
              dayOfWeek: s.dayOfWeek,
              startTime: s.startTime,
              endTime: s.endTime,
            ),
          )
          .toList();
      final result = await _remote.replaceMyAvailability(dtos);
      return result.map((dto) => dto.toEntity()).toList();
    } on HomeServiceAvailabilityFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceAvailabilityFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<AvailabilityException>> getMyExceptions() async {
    try {
      final dtos = await _remote.getMyExceptions();
      return dtos.map((dto) => dto.toEntity()).toList();
    } on HomeServiceAvailabilityFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceAvailabilityFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<AvailabilityException>> replaceMyExceptions(
    List<AvailabilityException> exceptions,
  ) async {
    try {
      final dtos = exceptions
          .map(
            (e) => AvailabilityExceptionDto(
              date: e.date,
              isUnavailable: e.isUnavailable,
              startTime: e.startTime,
              endTime: e.endTime,
            ),
          )
          .toList();
      final result = await _remote.replaceMyExceptions(dtos);
      return result.map((dto) => dto.toEntity()).toList();
    } on HomeServiceAvailabilityFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceAvailabilityFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
