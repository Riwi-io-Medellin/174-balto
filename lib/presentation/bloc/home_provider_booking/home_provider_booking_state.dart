import 'package:equatable/equatable.dart';

import '../../../domain/entities/home_service_booking.dart';

abstract class HomeProviderBookingState extends Equatable {
  const HomeProviderBookingState();
}

class HomeProviderBookingInitial extends HomeProviderBookingState {
  const HomeProviderBookingInitial();

  @override
  List<Object?> get props => [];
}

class HomeProviderBookingLoading extends HomeProviderBookingState {
  const HomeProviderBookingLoading();

  @override
  List<Object?> get props => [];
}

class HomeProviderBookingLoaded extends HomeProviderBookingState {
  const HomeProviderBookingLoaded({
    required this.bookings,
    this.isPerformingAction = false,
    this.successMessage,
    this.errorMessage,
  });

  final List<HomeServiceBooking> bookings;
  final bool isPerformingAction;
  final String? successMessage;
  final String? errorMessage;

  List<HomeServiceBooking> get pending =>
      (bookings
          .where((b) => b.status == HomeServiceBookingStatus.pending)
          .toList()
        ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));

  List<HomeServiceBooking> get upcoming =>
      (bookings
          .where(
            (b) =>
                b.status == HomeServiceBookingStatus.accepted ||
                b.status == HomeServiceBookingStatus.inProgress,
          )
          .toList()
        ..sort((a, b) => a.slotStart.compareTo(b.slotStart)));

  List<HomeServiceBooking> get completed =>
      (bookings
          .where((b) => b.status == HomeServiceBookingStatus.completed)
          .toList()
        ..sort((a, b) => b.slotStart.compareTo(a.slotStart)));

  List<HomeServiceBooking> get cancelled =>
      (bookings
          .where(
            (b) =>
                b.status == HomeServiceBookingStatus.providerCancelled ||
                b.status == HomeServiceBookingStatus.clientCancelled ||
                b.status == HomeServiceBookingStatus.rejected,
          )
          .toList()
        ..sort((a, b) => b.slotStart.compareTo(a.slotStart)));

  HomeProviderBookingLoaded copyWith({
    List<HomeServiceBooking>? bookings,
    bool? isPerformingAction,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeProviderBookingLoaded(
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

class HomeProviderBookingError extends HomeProviderBookingState {
  const HomeProviderBookingError({required this.code, required this.message});

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
