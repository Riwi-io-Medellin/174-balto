import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/available_slot.dart';
import '../../../domain/entities/home_provider_service_item.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/home_service_booking_repository.dart';
import '../../../domain/repositories/home_service_provider_repository.dart';
import '../../../domain/repositories/pet_repository.dart';
import 'home_service_booking_state.dart';

class HomeServiceBookingCubit extends Cubit<HomeServiceBookingState> {
  HomeServiceBookingCubit(
    this._bookingRepository,
    this._providerRepository,
    this._petRepository,
  ) : super(const HomeServiceBookingInitial());

  final HomeServiceBookingRepository _bookingRepository;
  final HomeServiceProviderRepository _providerRepository;
  final PetRepository _petRepository;

  String? _providerId;
  HomeServiceBookingForm? _lastForm;

  Future<void> initialize(
    String providerId,
    List<HomeProviderServiceItem> services,
  ) async {
    _providerId = providerId;
    emit(const HomeServiceBookingLoading());
    try {
      final pets = await _petRepository.getMyPets();
      if (pets.isEmpty) {
        emit(const HomeServiceBookingNoPets());
        return;
      }
      final activeServices = services.where((s) => s.isActive).toList();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final initial = HomeServiceBookingForm(
        pets: pets,
        selectedPet: pets.length == 1 ? pets.first : null,
        services: activeServices,
        selectedService: activeServices.length == 1
            ? activeServices.first
            : null,
        selectedDate: today,
      );
      emit(initial);
      _loadSlots(initial);
    } on PetFailure catch (e) {
      emit(HomeServiceBookingError(e.code, e.message));
    } catch (e) {
      emit(HomeServiceBookingError('UNKNOWN', e.toString()));
    }
  }

  void selectPet(Pet pet) {
    final s = _form;
    if (s == null) return;
    emit(s.copyWith(selectedPet: pet));
  }

  void selectService(HomeProviderServiceItem service) {
    final s = _form;
    if (s == null) return;
    emit(s.copyWith(selectedService: service));
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

  void setServiceAddress(String text) {
    final s = _form;
    if (s == null) return;
    emit(s.copyWith(serviceAddress: text));
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

  Future<void> _loadSlots(HomeServiceBookingForm form) async {
    if (_providerId == null || form.selectedDate == null) return;
    final loadingState = form.copyWith(
      isLoadingSlots: true,
      availableSlots: const [],
      clearSlot: true,
      clearSlotsError: true,
    );
    emit(loadingState);
    try {
      final slots = await _providerRepository.getAvailableSlots(
        providerId: _providerId!,
        date: _formatDate(form.selectedDate!),
        durationMinutes: form.selectedDuration,
      );
      final current = _form;
      if (current != null) {
        emit(
          current.copyWith(
            availableSlots: slots,
            isLoadingSlots: false,
            clearSlotsError: true,
          ),
        );
      }
    } on HomeServiceFailure catch (e) {
      final current = _form;
      if (current != null) {
        emit(current.copyWith(isLoadingSlots: false, slotsError: e.message));
      }
    } catch (e) {
      final current = _form;
      if (current != null) {
        emit(
          current.copyWith(
            isLoadingSlots: false,
            slotsError: 'Could not load available slots.',
          ),
        );
      }
    }
  }

  Future<void> confirmBooking() async {
    final s = _form;
    if (s == null || !s.canConfirm || _providerId == null) return;
    _lastForm = s;
    emit(const HomeServiceBookingSubmitting());
    try {
      final booking = await _bookingRepository.createBooking(
        providerId: _providerId!,
        serviceTypeId: s.selectedService!.serviceTypeId,
        petId: s.selectedPet!.id,
        slotStart: s.selectedSlot!.start,
        durationMinutes: s.selectedDuration,
        serviceAddress: s.serviceAddress.trim().isEmpty
            ? null
            : s.serviceAddress.trim(),
        specialInstructions: s.instructions.trim().isEmpty
            ? null
            : s.instructions.trim(),
      );
      emit(HomeServiceBookingSuccess(booking));
    } on HomeServiceBookingFailure catch (e) {
      if (e.code == 'SLOT_NOT_AVAILABLE') {
        await _recoverFromConflict();
      } else {
        emit(HomeServiceBookingError(e.code, e.message));
      }
    } catch (e) {
      emit(HomeServiceBookingError('UNKNOWN', e.toString()));
    }
  }

  Future<void> _recoverFromConflict() async {
    final saved = _lastForm;
    if (saved == null || _providerId == null) return;

    final recovering = saved.copyWith(
      availableSlots: const [],
      clearSlot: true,
      isLoadingSlots: true,
      clearSlotsError: true,
    );
    emit(recovering);

    try {
      final slots = await _providerRepository.getAvailableSlots(
        providerId: _providerId!,
        date: _formatDate(saved.selectedDate!),
        durationMinutes: saved.selectedDuration,
      );
      emit(
        recovering.copyWith(
          availableSlots: slots,
          isLoadingSlots: false,
          hadConflict: true,
        ),
      );
    } catch (_) {
      emit(recovering.copyWith(isLoadingSlots: false, hadConflict: true));
    }
  }

  HomeServiceBookingForm? get _form =>
      state is HomeServiceBookingForm ? state as HomeServiceBookingForm : null;

  String _formatDate(DateTime d) => '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  String _pad(int n) => n.toString().padLeft(2, '0');
}
