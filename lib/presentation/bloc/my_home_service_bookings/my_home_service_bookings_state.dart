import 'package:equatable/equatable.dart';

import '../../../domain/entities/home_service_booking.dart';

abstract class MyHomeServiceBookingsState extends Equatable {
  const MyHomeServiceBookingsState();
}

class MyHomeServiceBookingsInitial extends MyHomeServiceBookingsState {
  const MyHomeServiceBookingsInitial();
  @override
  List<Object?> get props => [];
}

class MyHomeServiceBookingsLoading extends MyHomeServiceBookingsState {
  const MyHomeServiceBookingsLoading();
  @override
  List<Object?> get props => [];
}

class MyHomeServiceBookingsLoaded extends MyHomeServiceBookingsState {
  const MyHomeServiceBookingsLoaded({
    required this.bookings,
    this.isPerformingAction = false,
    this.successMessage,
    this.errorMessage,
  });

  final List<HomeServiceBooking> bookings;
  final bool isPerformingAction;
  final String? successMessage;
  final String? errorMessage;

  List<HomeServiceBooking> get pending => (bookings
        .where((b) => b.status == HomeServiceBookingStatus.pending)
        .toList()
      ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));

  List<HomeServiceBooking> get upcoming => (bookings
        .where((b) =>
            b.status == HomeServiceBookingStatus.accepted ||
            b.status == HomeServiceBookingStatus.inProgress)
        .toList()
      ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));

  List<HomeServiceBooking> get history => (bookings
        .where((b) =>
            b.status == HomeServiceBookingStatus.completed ||
            b.status == HomeServiceBookingStatus.clientCancelled ||
            b.status == HomeServiceBookingStatus.providerCancelled ||
            b.status == HomeServiceBookingStatus.rejected)
        .toList()
      ..sort((a, b) => b.slotStart.compareTo(a.slotStart)));

  bool get isEmpty => pending.isEmpty && upcoming.isEmpty && history.isEmpty;

  MyHomeServiceBookingsLoaded copyWith({
    List<HomeServiceBooking>? bookings,
    bool? isPerformingAction,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyHomeServiceBookingsLoaded(
      bookings: bookings ?? this.bookings,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [bookings, isPerformingAction, successMessage, errorMessage];
}

class MyHomeServiceBookingsError extends MyHomeServiceBookingsState {
  const MyHomeServiceBookingsError({required this.code, required this.message});

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
