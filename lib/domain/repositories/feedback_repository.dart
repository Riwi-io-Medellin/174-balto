import '../entities/feedback_summary.dart';

abstract class FeedbackRepository {
  Future<FeedbackSummary?> getByWalker(String walkerId);
}

class FeedbackFailure implements Exception {
  FeedbackFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'FeedbackFailure($code): $message';
}
