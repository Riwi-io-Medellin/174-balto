import 'package:equatable/equatable.dart';

import '../../../domain/entities/walk_booking.dart';

abstract class WalkerBookingState extends Equatable {
  const WalkerBookingState();
}

class WalkerBookingInitial extends WalkerBookingState {
  const WalkerBookingInitial();

  @override
  List<Object?> get props => [];
}

class WalkerBookingLoading extends WalkerBookingState {
  const WalkerBookingLoading();

  @override
  List<Object?> get props => [];
}

class WalkerBookingLoaded extends WalkerBookingState {
  const WalkerBookingLoaded({
    required this.bookings,
    this.isPerformingAction = false,
    this.successMessage,
    this.errorMessage,
  });

  final List<WalkBooking> bookings;
  final bool isPerformingAction;
  final String? successMessage;
  final String? errorMessage;

  List<WalkBooking> get pending =>
      (bookings.where((b) => b.status == WalkBookingStatus.pending).toList()
        ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));

  List<WalkBooking> get upcoming =>
      (bookings
          .where(
            (b) =>
                b.status == WalkBookingStatus.accepted ||
                b.status == WalkBookingStatus.inProgress,
          )
          .toList()
        ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));

  List<WalkBooking> get completed =>
      (bookings.where((b) => b.status == WalkBookingStatus.completed).toList()
        ..sort((a, b) => b.slotStart.compareTo(a.slotStart)));

  List<WalkBooking> get cancelled =>
      (bookings
          .where(
            (b) =>
                b.status == WalkBookingStatus.walkerCancelled ||
                b.status == WalkBookingStatus.ownerCancelled ||
                b.status == WalkBookingStatus.rejected,
          )
          .toList()
        ..sort((a, b) => b.slotStart.compareTo(a.slotStart)));

  WalkerBookingLoaded copyWith({
    List<WalkBooking>? bookings,
    bool? isPerformingAction,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalkerBookingLoaded(
      bookings: bookings ?? this.bookings,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    bookings,
    isPerformingAction,
    successMessage,
    errorMessage,
  ];
}

class WalkerBookingError extends WalkerBookingState {
  const WalkerBookingError({required this.code, required this.message});

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
