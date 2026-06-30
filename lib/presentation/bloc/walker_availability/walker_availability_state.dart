import 'package:equatable/equatable.dart';

import '../../../domain/entities/availability_exception.dart';
import '../../../domain/entities/availability_slot.dart';

abstract class WalkerAvailabilityState extends Equatable {
  const WalkerAvailabilityState();

  @override
  List<Object?> get props => [];
}

class WalkerAvailabilityInitial extends WalkerAvailabilityState {
  const WalkerAvailabilityInitial();
}

class WalkerAvailabilityLoading extends WalkerAvailabilityState {
  const WalkerAvailabilityLoading();
}

class WalkerAvailabilityLoaded extends WalkerAvailabilityState {
  const WalkerAvailabilityLoaded({
    required this.slots,
    required this.exceptions,
  });

  final List<AvailabilitySlot> slots;
  final List<AvailabilityException> exceptions;

  @override
  List<Object?> get props => [slots, exceptions];
}

class WalkerAvailabilityError extends WalkerAvailabilityState {
  const WalkerAvailabilityError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
