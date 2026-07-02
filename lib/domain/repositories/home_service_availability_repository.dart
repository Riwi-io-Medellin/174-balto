import '../entities/availability_exception.dart';
import '../entities/availability_slot.dart';

abstract class HomeServiceAvailabilityRepository {
  Future<List<AvailabilitySlot>> getMyAvailability();
  Future<List<AvailabilitySlot>> replaceMyAvailability(
    List<AvailabilitySlot> slots,
  );
  Future<List<AvailabilityException>> getMyExceptions();
  Future<List<AvailabilityException>> replaceMyExceptions(
    List<AvailabilityException> exceptions,
  );
}

class HomeServiceAvailabilityFailure implements Exception {
  HomeServiceAvailabilityFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeServiceAvailabilityFailure($code): $message';
}
