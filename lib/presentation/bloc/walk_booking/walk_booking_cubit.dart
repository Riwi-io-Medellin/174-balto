import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/available_slot.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/walk_booking_repository.dart';
import '../../../domain/repositories/walker_repository.dart';
import 'walk_booking_state.dart';

class WalkBookingCubit extends Cubit<WalkBookingState> {
  WalkBookingCubit(
    this._bookingRepository,
    this._walkerRepository,
    this._petRepository,
  ) : super(const WalkBookingInitial());

  final WalkBookingRepository _bookingRepository;
  final WalkerRepository _walkerRepository;
  final PetRepository _petRepository;

  String? _walkerId;
  WalkBookingForm? _lastForm;

  Future<void> initialize(String walkerId) async {
    _walkerId = walkerId;
    emit(const WalkBookingLoading());
    try {
      final pets = await _petRepository.getMyPets();
      if (pets.isEmpty) {
        emit(const WalkBookingNoPets());
        return;
      }
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final initial = WalkBookingForm(
        pets: pets,
        selectedPet: pets.length == 1 ? pets.first : null,
        selectedDate: tomorrow,
      );
      emit(initial);
      _loadSlots(initial);
    } on PetFailure catch (e) {
      emit(WalkBookingError(e.code, e.message));
    } catch (e) {
      emit(WalkBookingError('UNKNOWN', e.toString()));
    }
  }

  void selectPet(Pet pet) {
    final s = _form;
    if (s == null) return;
    emit(s.copyWith(selectedPet: pet));
  }

  void selectDuration(int minutes) {
    final s = _form;
    if (s == null) return;
    final updated = s.copyWith(
      selectedDuration: minutes,
      availableSlots: const [],
      clearSlot: true,
      clearSlotsError: true,
    );
    emit(updated);
    _loadSlots(updated);
  }

  void selectDate(DateTime date) {
    final s = _form;
    if (s == null) return;
    final updated = s.copyWith(
      selectedDate: date,
      availableSlots: const [],
      clearSlot: true,
      clearSlotsError: true,
    );
    emit(updated);
    _loadSlots(updated);
  }

  void selectSlot(AvailableSlot slot) {
    final s = _form;
    if (s == null) return;
    emit(s.copyWith(selectedSlot: slot));
  }

  void setInstructions(String text) {
    final s = _form;
    if (s == null) return;
    emit(s.copyWith(instructions: text));
  }

  Future<void> refreshSlots() async {
    final s = _form;
    if (s == null) return;
    _loadSlots(s);
  }

  Future<void> _loadSlots(WalkBookingForm form) async {
    if (_walkerId == null || form.selectedDate == null) return;
    final loadingState = form.copyWith(
      isLoadingSlots: true,
      availableSlots: const [],
      clearSlot: true,
      clearSlotsError: true,
    );
    emit(loadingState);
    try {
      final slots = await _walkerRepository.getAvailableSlots(
        walkerId: _walkerId!,
        date: _formatDate(form.selectedDate!),
        durationMinutes: form.selectedDuration,
      );
      final current = _form;
      if (current != null) {
        emit(current.copyWith(
          availableSlots: slots,
          isLoadingSlots: false,
          clearSlotsError: true,
        ));
      }
    } on WalkerFailure catch (e) {
      final current = _form;
      if (current != null) {
        emit(current.copyWith(
          isLoadingSlots: false,
          slotsError: e.message,
        ));
      }
    } catch (e) {
      final current = _form;
      if (current != null) {
        emit(current.copyWith(
          isLoadingSlots: false,
          slotsError: 'Could not load available slots.',
        ));
      }
    }
  }

  Future<void> confirmBooking() async {
    final s = _form;
    if (s == null || !s.canConfirm || _walkerId == null) return;
    _lastForm = s;
    emit(const WalkBookingSubmitting());
    try {
      final booking = await _bookingRepository.createBooking(
        walkerId: _walkerId!,
        petId: s.selectedPet!.id,
        slotStart: s.selectedSlot!.start,
        durationMinutes: s.selectedDuration,
        specialInstructions:
            s.instructions.trim().isEmpty ? null : s.instructions.trim(),
      );
      emit(WalkBookingSuccess(booking));
    } on WalkBookingFailure catch (e) {
      if (e.code == 'SLOT_NOT_AVAILABLE') {
        await _recoverFromConflict();
      } else {
        emit(WalkBookingError(e.code, e.message));
      }
    } catch (e) {
      emit(WalkBookingError('UNKNOWN', e.toString()));
    }
  }

  Future<void> _recoverFromConflict() async {
    final saved = _lastForm;
    if (saved == null || _walkerId == null) return;

    final recovering = saved.copyWith(
      availableSlots: const [],
      clearSlot: true,
      isLoadingSlots: true,
      clearSlotsError: true,
    );
    emit(recovering);

    try {
      final slots = await _walkerRepository.getAvailableSlots(
        walkerId: _walkerId!,
        date: _formatDate(saved.selectedDate!),
        durationMinutes: saved.selectedDuration,
      );
      emit(recovering.copyWith(
        availableSlots: slots,
        isLoadingSlots: false,
        hadConflict: true,
      ));
    } catch (_) {
      emit(recovering.copyWith(
        isLoadingSlots: false,
        hadConflict: true,
      ));
    }
  }

  WalkBookingForm? get _form =>
      state is WalkBookingForm ? state as WalkBookingForm : null;

  String _formatDate(DateTime d) {
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
