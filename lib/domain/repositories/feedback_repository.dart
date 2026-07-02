import '../entities/feedback_summary.dart';

abstract class FeedbackRepository {
  Future<FeedbackSummary?> getByWalker(String walkerId);
  Future<FeedbackSummary?> getByBusiness(String businessId);
  Future<FeedbackSummary?> getByHomeServiceProvider(String providerId);
  Future<void> createWalkerReview({
    required String walkerId,
    required int rating,
    String? comment,
  });
  Future<void> createBusinessReview({
    required String businessId,
    required int rating,
    String? comment,
  });
  Future<void> createHomeServiceProviderReview({
    required String providerId,
    required int rating,
    String? comment,
  });
}

class FeedbackFailure implements Exception {
  FeedbackFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'FeedbackFailure($code): $message';
}
