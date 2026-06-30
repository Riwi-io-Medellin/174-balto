import '../entities/coach_message.dart';

abstract class CoachRepository {
  Future<String> sendMessage(String message, List<CoachMessage> history);
}

class CoachFailure implements Exception {
  CoachFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'CoachFailure($code): $message';
}
