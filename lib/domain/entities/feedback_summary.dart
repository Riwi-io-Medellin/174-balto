import 'package:equatable/equatable.dart';

class FeedbackSummary extends Equatable {
  const FeedbackSummary({
    required this.targetId,
    required this.targetType,
    required this.averageRating,
    required this.totalReviews,
  });

  final String targetId;
  final String targetType;
  final double averageRating;
  final int totalReviews;

  @override
  List<Object?> get props =>
      [targetId, targetType, averageRating, totalReviews];
}
