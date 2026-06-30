import '../../domain/entities/walk_booking.dart';

class BookingResponseDto {
  const BookingResponseDto({
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

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) {
    return BookingResponseDto(
      id: json['id'] as String,
      walkerId: json['walkerId'] as String,
      petId: json['petId'] as String,
      clientUserId: json['clientUserId'] as String?,
      status: _parseStatus(json['status'] as String),
      slotStart: _parseLocal(json['slotStart'] as String),
      durationMinutes: json['durationMinutes'] as int,
      snapshotHourlyRate: (json['snapshotHourlyRate'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      specialInstructions: json['specialInstructions'] as String?,
      createdAt: _parseLocal(json['createdAt'] as String),
      walkSessionId: json['walkSessionId'] as String?,
      actualDistanceMeters: (json['totalDistanceMeters'] as num?)?.toDouble(),
      actualDurationSeconds: json['totalDurationSeconds'] as int?,
      ownerLatitude: (json['ownerLatitude'] as num?)?.toDouble(),
      ownerLongitude: (json['ownerLongitude'] as num?)?.toDouble(),
      ownerAddress: json['ownerAddress'] as String?,
    );
  }

  // Backend sends local times incorrectly marked with Z — strip the suffix
  // so Dart treats them as local rather than converting from UTC.
  static DateTime _parseLocal(String s) =>
      DateTime.parse(s.replaceFirst(RegExp(r'Z$'), ''));

  static WalkBookingStatus _parseStatus(String s) {
    switch (s) {
      case 'accepted':
        return WalkBookingStatus.accepted;
      case 'in_progress':
        return WalkBookingStatus.inProgress;
      case 'completed':
        return WalkBookingStatus.completed;
      case 'rejected':
        return WalkBookingStatus.rejected;
      case 'walker_cancelled':
        return WalkBookingStatus.walkerCancelled;
      case 'owner_cancelled':
        return WalkBookingStatus.ownerCancelled;
      default:
        return WalkBookingStatus.pending;
    }
  }

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

  WalkBooking toEntity() => WalkBooking(
        id: id,
        walkerId: walkerId,
        petId: petId,
        clientUserId: clientUserId,
        status: status,
        slotStart: slotStart,
        durationMinutes: durationMinutes,
        snapshotHourlyRate: snapshotHourlyRate,
        totalPrice: totalPrice,
        specialInstructions: specialInstructions,
        createdAt: createdAt,
        walkSessionId: walkSessionId,
        actualDistanceMeters: actualDistanceMeters,
        actualDurationSeconds: actualDurationSeconds,
        ownerLatitude: ownerLatitude,
        ownerLongitude: ownerLongitude,
        ownerAddress: ownerAddress,
      );
}
