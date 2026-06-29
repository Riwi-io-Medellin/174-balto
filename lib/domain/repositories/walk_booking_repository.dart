import '../entities/walk_booking.dart';

abstract class WalkBookingRepository {
  Future<WalkBooking> createBooking({
    required String walkerId,
    required String petId,
    required DateTime slotStart,
    required int durationMinutes,
    String? specialInstructions,
  });

  Future<List<WalkBooking>> getMyBookings({String? status});

  Future<void> cancelBooking(String bookingId);

  // Walker-side booking management
  Future<List<WalkBooking>> getWalkerBookings({String? status});
  Future<void> acceptBooking(String bookingId);
  Future<void> rejectBooking(String bookingId);
  Future<void> walkerCancelBooking(String bookingId);
}

class WalkBookingFailure implements Exception {
  const WalkBookingFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'WalkBookingFailure($code): $message';
}
