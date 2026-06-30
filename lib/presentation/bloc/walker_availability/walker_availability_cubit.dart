import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/availability_exception.dart';
import '../../../domain/entities/availability_slot.dart';
import '../../../domain/repositories/walker_availability_repository.dart';
import 'walker_availability_state.dart';

class WalkerAvailabilityCubit extends Cubit<WalkerAvailabilityState> {
  WalkerAvailabilityCubit(this._repository)
      : super(const WalkerAvailabilityInitial());

  final WalkerAvailabilityRepository _repository;

  Future<void> load() async {
    emit(const WalkerAvailabilityLoading());
    try {
      final results = await Future.wait([
        _repository.getMyAvailability(),
        _repository.getMyExceptions(),
      ]);
      final slots = results[0] as List<AvailabilitySlot>;
      final exceptions = results[1] as List<AvailabilityException>;
      emit(WalkerAvailabilityLoaded(
        slots: slots,
        exceptions: exceptions,
      ));
    } on WalkerAvailabilityFailure catch (e) {
      emit(WalkerAvailabilityError(e.code, e.message));
    } catch (e) {
      emit(WalkerAvailabilityError('UNKNOWN', e.toString()));
    }
  }

  Future<void> saveSlots(List<AvailabilitySlot> slots) async {
    emit(const WalkerAvailabilityLoading());
    try {
      await _repository.replaceMyAvailability(slots);
      // Reload fresh data from backend
      await load();
    } on WalkerAvailabilityFailure catch (e) {
      emit(WalkerAvailabilityError(e.code, e.message));
    } catch (e) {
      emit(WalkerAvailabilityError('UNKNOWN', e.toString()));
    }
  }

  Future<void> saveExceptions(List<AvailabilityException> exceptions) async {
    emit(const WalkerAvailabilityLoading());
    try {
      await _repository.replaceMyExceptions(exceptions);
      await load();
    } on WalkerAvailabilityFailure catch (e) {
      emit(WalkerAvailabilityError(e.code, e.message));
    } catch (e) {
      emit(WalkerAvailabilityError('UNKNOWN', e.toString()));
    }
  }
}
