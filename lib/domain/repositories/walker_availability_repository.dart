import '../entities/availability_exception.dart';
import '../entities/availability_slot.dart';

abstract class WalkerAvailabilityRepository {
  Future<List<AvailabilitySlot>> getMyAvailability();
  Future<List<AvailabilitySlot>> replaceMyAvailability(
    List<AvailabilitySlot> slots,
  );
  Future<List<AvailabilityException>> getMyExceptions();
  Future<List<AvailabilityException>> replaceMyExceptions(
    List<AvailabilityException> exceptions,
  );
}

class WalkerAvailabilityFailure implements Exception {
  WalkerAvailabilityFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'WalkerAvailabilityFailure($code): $message';
}
