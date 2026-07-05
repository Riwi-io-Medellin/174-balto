import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../entities/chat_message.dart';
import '../entities/walk_media.dart';

abstract class WalkSessionRepository {
  Future<String> startSession(String bookingId);
  Future<void> addLocation(String sessionId, double latitude, double longitude);
  Future<void> finishSession(
      String sessionId, double totalDistanceMeters, int totalDurationSeconds);
  Future<List<LatLng>> getRoute(String sessionId);
  Future<void> addMedia(String sessionId, String url, String type);
  Future<List<WalkMedia>> getSessionMedia(String sessionId);
  Future<ChatMessage> sendChatMessage(String sessionId, String text);
  Future<List<ChatMessage>> getChatMessages(String sessionId);
}

class WalkSessionFailure implements Exception {
  const WalkSessionFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'WalkSessionFailure($code): $message';
}
