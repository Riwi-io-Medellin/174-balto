import 'package:equatable/equatable.dart';

import '../../../domain/entities/availability_exception.dart';
import '../../../domain/entities/availability_slot.dart';

abstract class HomeServiceAvailabilityState extends Equatable {
  const HomeServiceAvailabilityState();

  @override
  List<Object?> get props => [];
}

class HomeServiceAvailabilityInitial extends HomeServiceAvailabilityState {
  const HomeServiceAvailabilityInitial();
}

class HomeServiceAvailabilityLoading extends HomeServiceAvailabilityState {
  const HomeServiceAvailabilityLoading();
}

class HomeServiceAvailabilityLoaded extends HomeServiceAvailabilityState {
  const HomeServiceAvailabilityLoaded({
    required this.slots,
    required this.exceptions,
  });

  final List<AvailabilitySlot> slots;
  final List<AvailabilityException> exceptions;

  @override
  List<Object?> get props => [slots, exceptions];
}

class HomeServiceAvailabilityError extends HomeServiceAvailabilityState {
  const HomeServiceAvailabilityError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
