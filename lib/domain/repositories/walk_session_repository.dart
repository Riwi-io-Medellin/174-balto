abstract class WalkSessionRepository {
  Future<String> startSession(String bookingId);
  Future<void> addLocation(String sessionId, double latitude, double longitude);
  Future<void> finishSession(
      String sessionId, double totalDistanceMeters, int totalDurationSeconds);
}

class WalkSessionFailure implements Exception {
  const WalkSessionFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'WalkSessionFailure($code): $message';
}
