import 'package:dio/dio.dart';

import '../../domain/entities/available_slot.dart';
import '../../domain/entities/walker.dart';
import '../../domain/repositories/walker_repository.dart';
import '../datasources/walker_remote_datasource.dart';

class WalkerRepositoryImpl implements WalkerRepository {
  WalkerRepositoryImpl(this._remote);

  final WalkerRemoteDataSource _remote;

  @override
  Future<List<Walker>> getWalkers({
    bool? available,
    String? workLocation,
  }) async {
    try {
      final result = await _remote.getWalkers(
        available: available,
        workLocation: workLocation,
      );
      return result.map((dto) => dto.toEntity()).toList();
    } on WalkerFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkerFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<WalkerSearchResult> searchWalkers({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required String date,
    required int durationMinutes,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remote.searchWalkers(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        date: date,
        durationMinutes: durationMinutes,
        page: page,
        pageSize: pageSize,
      );
      return WalkerSearchResult(
        items: result.items.map((dto) => dto.toEntity()).toList(),
        page: result.page,
        pageSize: result.pageSize,
        totalCount: result.totalCount,
      );
    } on WalkerFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkerFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<Walker> getWalkerDetail(
    String walkerId, {
    String? date,
    int? durationMinutes,
  }) async {
    try {
      final dto = await _remote.getWalkerDetail(
        walkerId,
        date: date,
        durationMinutes: durationMinutes,
      );
      return dto.toEntity();
    } on WalkerFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkerFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<AvailableSlot>> getAvailableSlots({
    required String walkerId,
    required String date,
    required int durationMinutes,
  }) async {
    try {
      return await _remote.getAvailableSlots(
        walkerId: walkerId,
        date: date,
        durationMinutes: durationMinutes,
      );
    } on WalkerFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkerFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
