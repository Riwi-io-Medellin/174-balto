import 'package:equatable/equatable.dart';

enum WalkBookingStatus {
  pending,
  accepted,
  inProgress,
  completed,
  rejected,
  walkerCancelled,
  ownerCancelled,
}

class WalkBooking extends Equatable {
  const WalkBooking({
    required this.id,
    required this.walkerId,
    required this.petId,
    required this.status,
    required this.slotStart,
    required this.durationMinutes,
    this.snapshotHourlyRate,
    this.totalPrice,
    this.specialInstructions,
    required this.createdAt,
    this.clientUserId,
    this.walkSessionId,
    this.actualDistanceMeters,
    this.actualDurationSeconds,
    this.ownerLatitude,
    this.ownerLongitude,
    this.ownerAddress,
  });

  final String id;
  final String walkerId;
  final String petId;
  final String? clientUserId;
  final WalkBookingStatus status;
  final DateTime slotStart;
  final int durationMinutes;
  final double? snapshotHourlyRate;
  final double? totalPrice;
  final String? specialInstructions;
  final DateTime createdAt;
  final String? walkSessionId;
  final double? actualDistanceMeters;
  final int? actualDurationSeconds;
  final double? ownerLatitude;
  final double? ownerLongitude;
  final String? ownerAddress;

  @override
  List<Object?> get props => [
        id,
        walkerId,
        petId,
        clientUserId,
        status,
        slotStart,
        durationMinutes,
        snapshotHourlyRate,
        totalPrice,
        specialInstructions,
        createdAt,
        walkSessionId,
        actualDistanceMeters,
        actualDurationSeconds,
        ownerLatitude,
        ownerLongitude,
        ownerAddress,
      ];
}
