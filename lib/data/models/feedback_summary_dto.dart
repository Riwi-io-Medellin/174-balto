import '../../domain/entities/feedback_summary.dart';

class FeedbackSummaryDto {
  FeedbackSummaryDto({
    required this.targetId,
    required this.targetType,
    required this.averageRating,
    required this.totalReviews,
  });

  final String targetId;
  final String targetType;
  final double averageRating;
  final int totalReviews;

  factory FeedbackSummaryDto.fromJson(Map<String, dynamic> json) {
    return FeedbackSummaryDto(
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
    );
  }

  FeedbackSummary toEntity() => FeedbackSummary(
        targetId: targetId,
        targetType: targetType,
        averageRating: averageRating,
        totalReviews: totalReviews,
      );
}
