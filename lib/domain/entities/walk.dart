import 'package:equatable/equatable.dart';

enum WalkStatus { inProgress, upcoming, completed }

class Walk extends Equatable {
  const Walk({
    required this.id,
    required this.petName,
    required this.petImageUrl,
    required this.walkerName,
    required this.walkerAvatarUrl,
    required this.walkerRating,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.distanceKm,
    this.meetingLocation,
    this.notes,
    this.userRating,
    this.elapsedMinutes = 0,
  });

  final String id;
  final String petName;
  final String petImageUrl;
  final String walkerName;
  final String walkerAvatarUrl;
  final double walkerRating;
  final DateTime scheduledAt;
  final int durationMinutes;
  final WalkStatus status;
  final double? distanceKm;
  final String? meetingLocation;
  final String? notes;
  final double? userRating;
  final int elapsedMinutes;

  @override
  List<Object?> get props => [id, status, scheduledAt];
}
