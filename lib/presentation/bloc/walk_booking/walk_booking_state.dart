import 'package:equatable/equatable.dart';

import '../../../domain/entities/available_slot.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/walk_booking.dart';

abstract class WalkBookingState extends Equatable {
  const WalkBookingState();

  @override
  List<Object?> get props => const [];
}

class WalkBookingInitial extends WalkBookingState {
  const WalkBookingInitial();
}

class WalkBookingLoading extends WalkBookingState {
  const WalkBookingLoading();
}

class WalkBookingNoPets extends WalkBookingState {
  const WalkBookingNoPets();
}

class WalkBookingForm extends WalkBookingState {
  const WalkBookingForm({
    required this.pets,
    this.selectedPet,
    this.selectedDuration = 60,
    this.selectedDate,
    this.availableSlots = const [],
    this.selectedSlot,
    this.instructions = '',
    this.isLoadingSlots = false,
    this.slotsError,
    this.hadConflict = false,
    this.ownerAddress,
    this.ownerCity,
    this.isExclusive = false,
  });

  final List<Pet> pets;
  final Pet? selectedPet;
  final int selectedDuration;
  final DateTime? selectedDate;
  final List<AvailableSlot> availableSlots;
  final AvailableSlot? selectedSlot;
  final String instructions;
  final bool isLoadingSlots;
  final String? slotsError;
  final String? ownerAddress;
  final String? ownerCity;
  final bool isExclusive;

  /// True for one state cycle to trigger a conflict warning toast.
  final bool hadConflict;

  bool get hasPickupAddress =>
      (ownerAddress != null && ownerAddress!.isNotEmpty) ||
      (ownerCity != null && ownerCity!.isNotEmpty);

  bool get canConfirm =>
      selectedPet != null && selectedSlot != null && !isLoadingSlots;

  WalkBookingForm copyWith({
    List<Pet>? pets,
    Pet? selectedPet,
    bool clearPet = false,
    int? selectedDuration,
    DateTime? selectedDate,
    List<AvailableSlot>? availableSlots,
    AvailableSlot? selectedSlot,
    bool clearSlot = false,
    String? instructions,
    bool? isLoadingSlots,
    String? slotsError,
    bool clearSlotsError = false,
    bool? hadConflict,
    String? ownerAddress,
    String? ownerCity,
    bool? isExclusive,
  }) {
    return WalkBookingForm(
      pets: pets ?? this.pets,
      selectedPet: clearPet ? null : (selectedPet ?? this.selectedPet),
      selectedDuration: selectedDuration ?? this.selectedDuration,
      selectedDate: selectedDate ?? this.selectedDate,
      availableSlots: availableSlots ?? this.availableSlots,
      selectedSlot: clearSlot ? null : (selectedSlot ?? this.selectedSlot),
      instructions: instructions ?? this.instructions,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      slotsError: clearSlotsError ? null : (slotsError ?? this.slotsError),
      hadConflict: hadConflict ?? false,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      ownerCity: ownerCity ?? this.ownerCity,
      isExclusive: isExclusive ?? this.isExclusive,
    );
  }

  @override
  List<Object?> get props => [
    pets,
    selectedPet,
    selectedDuration,
    selectedDate,
    availableSlots,
    selectedSlot,
    instructions,
    isLoadingSlots,
    slotsError,
    hadConflict,
    ownerAddress,
    ownerCity,
    isExclusive,
  ];
}

class WalkBookingSubmitting extends WalkBookingState {
  const WalkBookingSubmitting();
}

class WalkBookingSuccess extends WalkBookingState {
  const WalkBookingSuccess(this.booking);

  final WalkBooking booking;

  @override
  List<Object?> get props => [booking];
}

class WalkBookingError extends WalkBookingState {
  const WalkBookingError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
