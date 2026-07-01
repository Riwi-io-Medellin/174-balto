import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
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

  @override
  List<Object?> get props =>
      [id, userId, userName, userAvatarUrl, rating, comment, createdAt];
}
