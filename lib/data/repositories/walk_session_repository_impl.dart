import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/repositories/walk_session_repository.dart';
import '../datasources/walk_session_remote_datasource.dart';

class WalkSessionRepositoryImpl implements WalkSessionRepository {
  WalkSessionRepositoryImpl(this._remote);

  final WalkSessionRemoteDataSource _remote;

  @override
  Future<String> startSession(String bookingId) async {
    try {
      return await _remote.startSession(bookingId);
    } on WalkSessionFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkSessionFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> addLocation(
      String sessionId, double latitude, double longitude) async {
    try {
      await _remote.addLocation(sessionId, latitude, longitude);
    } on WalkSessionFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkSessionFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> finishSession(
      String sessionId, double totalDistanceMeters, int totalDurationSeconds) async {
    try {
      await _remote.finishSession(sessionId, totalDistanceMeters, totalDurationSeconds);
    } on WalkSessionFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkSessionFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<LatLng>> getRoute(String sessionId) async {
    try {
      return await _remote.getRoute(sessionId);
    } on WalkSessionFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkSessionFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
