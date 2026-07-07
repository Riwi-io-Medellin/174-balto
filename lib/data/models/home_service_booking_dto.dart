import '../../domain/entities/home_service_booking.dart';

class HomeServiceBookingResponseDto {
  const HomeServiceBookingResponseDto({
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
  });

  factory HomeServiceBookingResponseDto.fromJson(Map<String, dynamic> json) {
    return HomeServiceBookingResponseDto(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      serviceTypeId: json['serviceTypeId'] as String,
      petId: json['petId'] as String,
      clientUserId: json['clientUserId'] as String?,
      status: _parseStatus(json['status'] as String),
      slotStart: _parseLocal(json['slotStart'] as String),
      durationMinutes: json['durationMinutes'] as int,
      snapshotPrice: (json['snapshotPrice'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      serviceAddress: json['serviceAddress'] as String?,
      serviceLatitude: (json['serviceLatitude'] as num?)?.toDouble(),
      serviceLongitude: (json['serviceLongitude'] as num?)?.toDouble(),
      specialInstructions: json['specialInstructions'] as String?,
      createdAt: _parseLocal(json['createdAt'] as String),
      homeServiceSessionId: json['homeServiceSessionId'] as String?,
      providerName: json['providerName'] as String?,
      providerPhotoUrl: json['providerPhotoUrl'] as String?,
    );
  }

  // Backend sends local (Colombia) times incorrectly marked with Z — strip
  // the suffix so Dart treats them as local rather than converting from UTC.
  // (Same quirk as WalkBooking's BookingResponseDto.)
  static DateTime _parseLocal(String s) =>
      DateTime.parse(s.replaceFirst(RegExp(r'Z$'), ''));

  static HomeServiceBookingStatus _parseStatus(String s) {
    switch (s) {
      case 'accepted':
        return HomeServiceBookingStatus.accepted;
      case 'rejected':
        return HomeServiceBookingStatus.rejected;
      case 'provider_cancelled':
        return HomeServiceBookingStatus.providerCancelled;
      case 'client_cancelled':
        return HomeServiceBookingStatus.clientCancelled;
      case 'in_progress':
        return HomeServiceBookingStatus.inProgress;
      case 'completed':
        return HomeServiceBookingStatus.completed;
      default:
        return HomeServiceBookingStatus.pending;
    }
  }

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

  HomeServiceBooking toEntity() => HomeServiceBooking(
    id: id,
    providerId: providerId,
    serviceTypeId: serviceTypeId,
    petId: petId,
    clientUserId: clientUserId,
    status: status,
    slotStart: slotStart,
    durationMinutes: durationMinutes,
    snapshotPrice: snapshotPrice,
    totalPrice: totalPrice,
    serviceAddress: serviceAddress,
    serviceLatitude: serviceLatitude,
    serviceLongitude: serviceLongitude,
    specialInstructions: specialInstructions,
    createdAt: createdAt,
    homeServiceSessionId: homeServiceSessionId,
    providerName: providerName,
    providerPhotoUrl: providerPhotoUrl,
  );
}
