import 'package:equatable/equatable.dart';

import 'review.dart';

class FeedbackSummary extends Equatable {
  const FeedbackSummary({
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
  final List<Review> reviews;

  @override
  List<Object?> get props =>
      [targetId, targetType, averageRating, totalReviews, reviews];
}
