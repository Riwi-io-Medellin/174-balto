import 'package:equatable/equatable.dart';

import '../../../domain/entities/available_slot.dart';
import '../../../domain/entities/home_provider_service_item.dart';
import '../../../domain/entities/home_service_booking.dart';
import '../../../domain/entities/pet.dart';

abstract class HomeServiceBookingState extends Equatable {
  const HomeServiceBookingState();

  @override
  List<Object?> get props => const [];
}

class HomeServiceBookingInitial extends HomeServiceBookingState {
  const HomeServiceBookingInitial();
}

class HomeServiceBookingLoading extends HomeServiceBookingState {
  const HomeServiceBookingLoading();
}

class HomeServiceBookingNoPets extends HomeServiceBookingState {
  const HomeServiceBookingNoPets();
}

class HomeServiceBookingForm extends HomeServiceBookingState {
  const HomeServiceBookingForm({
    required this.pets,
    this.selectedPet,
    required this.services,
    this.selectedService,
    this.selectedDuration = 60,
    this.selectedDate,
    this.availableSlots = const [],
    this.selectedSlot,
    this.serviceAddress = '',
    this.instructions = '',
    this.isLoadingSlots = false,
    this.slotsError,
    this.hadConflict = false,
  });

  final List<Pet> pets;
  final Pet? selectedPet;
  final List<HomeProviderServiceItem> services;
  final HomeProviderServiceItem? selectedService;
  final int selectedDuration;
  final DateTime? selectedDate;
  final List<AvailableSlot> availableSlots;
  final AvailableSlot? selectedSlot;
  final String serviceAddress;
  final String instructions;
  final bool isLoadingSlots;
  final String? slotsError;

  /// True for one state cycle to trigger a conflict warning toast.
  final bool hadConflict;

  bool get canConfirm =>
      selectedPet != null &&
      selectedSlot != null &&
      selectedService != null &&
      !isLoadingSlots;

  HomeServiceBookingForm copyWith({
    List<Pet>? pets,
    Pet? selectedPet,
    bool clearPet = false,
    List<HomeProviderServiceItem>? services,
    HomeProviderServiceItem? selectedService,
    int? selectedDuration,
    DateTime? selectedDate,
    List<AvailableSlot>? availableSlots,
    AvailableSlot? selectedSlot,
    bool clearSlot = false,
    String? serviceAddress,
    String? instructions,
    bool? isLoadingSlots,
    String? slotsError,
    bool clearSlotsError = false,
    bool? hadConflict,
  }) {
    return HomeServiceBookingForm(
      pets: pets ?? this.pets,
      selectedPet: clearPet ? null : (selectedPet ?? this.selectedPet),
      services: services ?? this.services,
      selectedService: selectedService ?? this.selectedService,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      selectedDate: selectedDate ?? this.selectedDate,
      availableSlots: availableSlots ?? this.availableSlots,
      selectedSlot: clearSlot ? null : (selectedSlot ?? this.selectedSlot),
      serviceAddress: serviceAddress ?? this.serviceAddress,
      instructions: instructions ?? this.instructions,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      slotsError: clearSlotsError ? null : (slotsError ?? this.slotsError),
      hadConflict: hadConflict ?? false,
    );
  }

  @override
  List<Object?> get props => [
    pets,
    selectedPet,
    services,
    selectedService,
    selectedDuration,
    selectedDate,
    availableSlots,
    selectedSlot,
    serviceAddress,
    instructions,
    isLoadingSlots,
    slotsError,
    hadConflict,
  ];
}

class HomeServiceBookingSubmitting extends HomeServiceBookingState {
  const HomeServiceBookingSubmitting();
}

class HomeServiceBookingSuccess extends HomeServiceBookingState {
  const HomeServiceBookingSuccess(this.booking);

  final HomeServiceBooking booking;

  @override
  List<Object?> get props => [booking];
}

class HomeServiceBookingError extends HomeServiceBookingState {
  const HomeServiceBookingError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
