import 'package:equatable/equatable.dart';

enum HomeServiceBookingStatus {
  pending,
  accepted,
  rejected,
  providerCancelled,
  clientCancelled,
  inProgress,
  completed,
}

class HomeServiceBooking extends Equatable {
  const HomeServiceBooking({
    required this.id,
    required this.providerId,
    required this.serviceTypeId,
    required this.petId,
    required this.status,
    required this.slotStart,
    required this.durationMinutes,
    this.snapshotPrice,
    this.totalPrice,
    this.serviceAddress,
    this.serviceLatitude,
    this.serviceLongitude,
    this.specialInstructions,
    required this.createdAt,
    this.clientUserId,
    this.homeServiceSessionId,
    this.providerName,
    this.providerPhotoUrl,
    this.serviceTypeName,
  });

  final String id;
  final String providerId;
  final String serviceTypeId;
  final String petId;
  final String? clientUserId;
  final HomeServiceBookingStatus status;
  final DateTime slotStart;
  final int durationMinutes;
  final double? snapshotPrice;
  final double? totalPrice;
  final String? serviceAddress;
  final double? serviceLatitude;
  final double? serviceLongitude;
  final String? specialInstructions;
  final DateTime createdAt;
  final String? homeServiceSessionId;
  final String? providerName;
  final String? providerPhotoUrl;
  final String? serviceTypeName;

  @override
  List<Object?> get props => [
    id,
    providerId,
    serviceTypeId,
    petId,
    clientUserId,
    status,
    slotStart,
    durationMinutes,
    snapshotPrice,
    totalPrice,
    serviceAddress,
    serviceLatitude,
    serviceLongitude,
    specialInstructions,
    createdAt,
    homeServiceSessionId,
    providerName,
    providerPhotoUrl,
    serviceTypeName,
  ];
}
