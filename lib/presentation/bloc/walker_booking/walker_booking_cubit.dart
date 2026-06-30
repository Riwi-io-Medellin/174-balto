import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/walk_booking_repository.dart';
import 'walker_booking_state.dart';

class WalkerBookingCubit extends Cubit<WalkerBookingState> {
  WalkerBookingCubit(this._repository) : super(const WalkerBookingInitial());

  final WalkBookingRepository _repository;

  Future<void> load() async {
    emit(const WalkerBookingLoading());
    try {
      final bookings = await _repository.getWalkerBookings();
      emit(WalkerBookingLoaded(bookings: bookings));
    } on WalkBookingFailure catch (e) {
      emit(WalkerBookingError(code: e.code, message: e.message));
    } catch (_) {
      emit(const WalkerBookingError(
        code: 'UNKNOWN',
        message: 'An unexpected error occurred.',
      ));
    }
  }

  Future<void> refresh() async {
    final current = state;
    try {
      final bookings = await _repository.getWalkerBookings();
      emit(WalkerBookingLoaded(bookings: bookings));
    } on WalkBookingFailure catch (e) {
      if (current is WalkerBookingLoaded) {
        emit(current.copyWith(errorMessage: e.message, clearError: false));
      } else {
        emit(WalkerBookingError(code: e.code, message: e.message));
      }
    } catch (_) {
      if (current is WalkerBookingLoaded) {
        emit(current.copyWith(
          errorMessage: 'Could not refresh bookings.',
          clearError: false,
        ));
      }
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    await _runAction(
      () => _repository.acceptBooking(bookingId),
      'Booking accepted.',
    );
  }

  Future<void> rejectBooking(String bookingId) async {
    await _runAction(
      () => _repository.rejectBooking(bookingId),
      'Booking rejected.',
    );
  }

  Future<void> cancelBooking(String bookingId) async {
    await _runAction(
      () => _repository.walkerCancelBooking(bookingId),
      'Booking cancelled.',
    );
  }

  void clearMessages() {
    final current = state;
    if (current is WalkerBookingLoaded) {
      emit(current.copyWith(clearSuccess: true, clearError: true));
    }
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMsg,
  ) async {
    final current = state;
    if (current is! WalkerBookingLoaded) return;
    if (current.isPerformingAction) return;

    emit(current.copyWith(isPerformingAction: true));

    try {
      await action();
      final bookings = await _repository.getWalkerBookings();
      emit(WalkerBookingLoaded(
        bookings: bookings,
        successMessage: successMsg,
      ));
    } on WalkBookingFailure catch (e) {
      emit(current.copyWith(
        isPerformingAction: false,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isPerformingAction: false,
        errorMessage: 'An unexpected error occurred.',
      ));
    }
  }
}
