import '../entities/home_service_booking.dart';

abstract class HomeServiceBookingRepository {
  Future<HomeServiceBooking> createBooking({
    required String providerId,
    required String serviceTypeId,
    required String petId,
    required DateTime slotStart,
    required int durationMinutes,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
  });

  Future<List<HomeServiceBooking>> getMyBookings({String? status});

  Future<void> clientCancelBooking(String bookingId);

  // Provider-side booking management
  Future<List<HomeServiceBooking>> getProviderBookings({String? status});
  Future<void> acceptBooking(String bookingId);
  Future<void> rejectBooking(String bookingId);
  Future<void> providerCancelBooking(String bookingId);

  // Session (status-only, no live map — deferred scope)
  Future<void> startSession(String bookingId);
  Future<void> finishSession(String sessionId);
}

class HomeServiceBookingFailure implements Exception {
  const HomeServiceBookingFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeServiceBookingFailure($code): $message';
}
