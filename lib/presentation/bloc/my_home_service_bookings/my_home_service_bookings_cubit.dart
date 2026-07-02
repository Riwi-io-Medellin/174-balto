import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/home_service_booking_repository.dart';
import 'my_home_service_bookings_state.dart';

class MyHomeServiceBookingsCubit extends Cubit<MyHomeServiceBookingsState> {
  MyHomeServiceBookingsCubit(this._repository)
      : super(const MyHomeServiceBookingsInitial());

  final HomeServiceBookingRepository _repository;

  Future<void> load() async {
    emit(const MyHomeServiceBookingsLoading());
    try {
      final bookings = await _repository.getMyBookings();
      emit(MyHomeServiceBookingsLoaded(bookings: bookings));
    } on HomeServiceBookingFailure catch (e) {
      emit(MyHomeServiceBookingsLoaded(bookings: [], errorMessage: e.message));
    } catch (_) {
      emit(const MyHomeServiceBookingsLoaded(
        bookings: [],
        errorMessage: 'Could not load bookings.',
      ));
    }
  }

  Future<void> refresh() async {
    final current = state;
    try {
      final bookings = await _repository.getMyBookings();
      emit(MyHomeServiceBookingsLoaded(bookings: bookings));
    } on HomeServiceBookingFailure catch (e) {
      if (current is MyHomeServiceBookingsLoaded) {
        emit(current.copyWith(errorMessage: e.message));
      } else {
        emit(MyHomeServiceBookingsLoaded(bookings: [], errorMessage: e.message));
      }
    } catch (_) {
      if (current is MyHomeServiceBookingsLoaded) {
        emit(current.copyWith(errorMessage: 'Could not refresh bookings.'));
      }
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final current = state;
    if (current is! MyHomeServiceBookingsLoaded || current.isPerformingAction) return;
    emit(current.copyWith(isPerformingAction: true));
    try {
      await _repository.clientCancelBooking(bookingId);
      final bookings = await _repository.getMyBookings();
      emit(MyHomeServiceBookingsLoaded(bookings: bookings, successMessage: 'Booking cancelled.'));
    } on HomeServiceBookingFailure catch (e) {
      emit(current.copyWith(isPerformingAction: false, errorMessage: e.message));
    } catch (_) {
      emit(current.copyWith(isPerformingAction: false, errorMessage: 'An unexpected error occurred.'));
    }
  }

  void clearMessages() {
    final current = state;
    if (current is MyHomeServiceBookingsLoaded) {
      emit(current.copyWith(clearSuccess: true, clearError: true));
    }
  }
}
