import '../../domain/entities/review.dart';

class ReviewDto {
  ReviewDto({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Anonymous',
      userAvatarUrl: json['userAvatarUrl'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Review toEntity() => Review(
    id: id,
    userId: userId,
    userName: userName,
    userAvatarUrl: userAvatarUrl,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
  );
}
