import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/availability_exception.dart';
import '../../../domain/entities/availability_slot.dart';
import '../../../domain/repositories/home_service_availability_repository.dart';
import 'home_service_availability_state.dart';

class HomeServiceAvailabilityCubit extends Cubit<HomeServiceAvailabilityState> {
  HomeServiceAvailabilityCubit(this._repository)
      : super(const HomeServiceAvailabilityInitial());

  final HomeServiceAvailabilityRepository _repository;

  Future<void> load() async {
    emit(const HomeServiceAvailabilityLoading());
    try {
      final results = await Future.wait([
        _repository.getMyAvailability(),
        _repository.getMyExceptions(),
      ]);
      final slots = results[0] as List<AvailabilitySlot>;
      final exceptions = results[1] as List<AvailabilityException>;
      emit(HomeServiceAvailabilityLoaded(
        slots: slots,
        exceptions: exceptions,
      ));
    } on HomeServiceAvailabilityFailure catch (e) {
      emit(HomeServiceAvailabilityError(e.code, e.message));
    } catch (e) {
      emit(HomeServiceAvailabilityError('UNKNOWN', e.toString()));
    }
  }

  Future<void> saveSlots(List<AvailabilitySlot> slots) async {
    emit(const HomeServiceAvailabilityLoading());
    try {
      await _repository.replaceMyAvailability(slots);
      await load();
    } on HomeServiceAvailabilityFailure catch (e) {
      emit(HomeServiceAvailabilityError(e.code, e.message));
    } catch (e) {
      emit(HomeServiceAvailabilityError('UNKNOWN', e.toString()));
    }
  }

  Future<void> saveExceptions(List<AvailabilityException> exceptions) async {
    emit(const HomeServiceAvailabilityLoading());
    try {
      await _repository.replaceMyExceptions(exceptions);
      await load();
    } on HomeServiceAvailabilityFailure catch (e) {
      emit(HomeServiceAvailabilityError(e.code, e.message));
    } catch (e) {
      emit(HomeServiceAvailabilityError('UNKNOWN', e.toString()));
    }
  }
}
