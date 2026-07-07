import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/walk_media.dart';
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
    String sessionId,
    double latitude,
    double longitude,
  ) async {
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
    String sessionId,
    double totalDistanceMeters,
    int totalDurationSeconds,
  ) async {
    try {
      await _remote.finishSession(
        sessionId,
        totalDistanceMeters,
        totalDurationSeconds,
      );
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

  @override
  Future<void> addMedia(String sessionId, String url, String type) async {
    try {
      await _remote.addMedia(sessionId, url, type);
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
  Future<List<WalkMedia>> getSessionMedia(String sessionId) async {
    try {
      return await _remote.getSessionMedia(sessionId);
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
  Future<ChatMessage> sendChatMessage(String sessionId, String text) async {
    try {
      return await _remote.sendChatMessage(sessionId, text);
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
  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    try {
      return await _remote.getChatMessages(sessionId);
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
