import 'package:equatable/equatable.dart';

import '../../../domain/entities/walk_booking.dart';

abstract class MyWalksState extends Equatable {
  const MyWalksState();
}

class MyWalksInitial extends MyWalksState {
  const MyWalksInitial();
  @override
  List<Object?> get props => [];
}

class MyWalksLoading extends MyWalksState {
  const MyWalksLoading();
  @override
  List<Object?> get props => [];
}

class MyWalksLoaded extends MyWalksState {
  const MyWalksLoaded({
    required this.bookings,
    this.isPerformingAction = false,
    this.successMessage,
    this.errorMessage,
  });

  final List<WalkBooking> bookings;
  final bool isPerformingAction;
  final String? successMessage;
  final String? errorMessage;

  List<WalkBooking> get inProgress {
    final now = DateTime.now();
    return (bookings.where((b) {
      // Backend sets status to "in_progress" once walker starts — always live.
      if (b.status == WalkBookingStatus.inProgress) return true;
      // Accepted + inside scheduled window = in progress too.
      if (b.status != WalkBookingStatus.accepted) return false;
      final end = b.slotStart.add(Duration(minutes: b.durationMinutes));
      return !b.slotStart.isAfter(now) && !end.isBefore(now);
    }).toList()
      ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));
  }

  List<WalkBooking> get pending => (bookings
      .where((b) => b.status == WalkBookingStatus.pending)
      .toList()
    ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));

  List<WalkBooking> get upcoming {
    final now = DateTime.now();
    return (bookings.where((b) {
      // inProgress bookings are shown in the inProgress section, not here.
      if (b.status == WalkBookingStatus.inProgress) return false;
      if (b.status != WalkBookingStatus.accepted) return false;
      return b.slotStart.isAfter(now);
    }).toList()
      ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));
  }

  List<WalkBooking> get history => (bookings
      .where(
        (b) =>
            b.status == WalkBookingStatus.completed ||
            b.status == WalkBookingStatus.ownerCancelled ||
            b.status == WalkBookingStatus.walkerCancelled ||
            b.status == WalkBookingStatus.rejected,
      )
      .toList()
    ..sort((a, b) => b.slotStart.compareTo(a.slotStart)));

  bool get isEmpty =>
      inProgress.isEmpty && pending.isEmpty && upcoming.isEmpty && history.isEmpty;

  MyWalksLoaded copyWith({
    List<WalkBooking>? bookings,
    bool? isPerformingAction,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyWalksLoaded(
      bookings: bookings ?? this.bookings,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
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

class MyWalksError extends MyWalksState {
  const MyWalksError({required this.code, required this.message});

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
