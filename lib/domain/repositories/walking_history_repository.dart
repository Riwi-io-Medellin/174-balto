abstract class WalkingHistoryRepository {
  Future<int> getMyWalkCount();
}

class WalkingHistoryFailure implements Exception {
  WalkingHistoryFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'WalkingHistoryFailure($code): $message';
}
