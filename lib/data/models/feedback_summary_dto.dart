import '../../domain/entities/feedback_summary.dart';
import 'review_dto.dart';

class FeedbackSummaryDto {
  FeedbackSummaryDto({
    required this.targetId,
    required this.targetType,
    required this.averageRating,
    required this.totalReviews,
    this.reviews = const [],
  });

  final String targetId;
  final String targetType;
  final double averageRating;
  final int totalReviews;
  final List<ReviewDto> reviews;

  factory FeedbackSummaryDto.fromJson(Map<String, dynamic> json) {
    final reviewsList =
        (json['reviews'] as List<dynamic>?)
            ?.map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return FeedbackSummaryDto(
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      reviews: reviewsList,
    );
  }

  FeedbackSummary toEntity() => FeedbackSummary(
    targetId: targetId,
    targetType: targetType,
    averageRating: averageRating,
    totalReviews: totalReviews,
    reviews: reviews.map((r) => r.toEntity()).toList(),
  );
}
