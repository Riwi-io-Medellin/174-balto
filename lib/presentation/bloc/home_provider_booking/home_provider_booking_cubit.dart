import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/home_service_booking_repository.dart';
import 'home_provider_booking_state.dart';

class HomeProviderBookingCubit extends Cubit<HomeProviderBookingState> {
  HomeProviderBookingCubit(this._repository)
    : super(const HomeProviderBookingInitial());

  final HomeServiceBookingRepository _repository;

  Future<void> load() async {
    emit(const HomeProviderBookingLoading());
    try {
      final bookings = await _repository.getProviderBookings();
      emit(HomeProviderBookingLoaded(bookings: bookings));
    } on HomeServiceBookingFailure catch (e) {
      emit(HomeProviderBookingError(code: e.code, message: e.message));
    } catch (_) {
      emit(
        const HomeProviderBookingError(
          code: 'UNKNOWN',
          message: 'An unexpected error occurred.',
        ),
      );
    }
  }

  Future<void> refresh() async {
    final current = state;
    try {
      final bookings = await _repository.getProviderBookings();
      emit(HomeProviderBookingLoaded(bookings: bookings));
    } on HomeServiceBookingFailure catch (e) {
      if (current is HomeProviderBookingLoaded) {
        emit(current.copyWith(errorMessage: e.message, clearError: false));
      } else {
        emit(HomeProviderBookingError(code: e.code, message: e.message));
      }
    } catch (_) {
      if (current is HomeProviderBookingLoaded) {
        emit(
          current.copyWith(
            errorMessage: 'Could not refresh bookings.',
            clearError: false,
          ),
        );
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
      () => _repository.providerCancelBooking(bookingId),
      'Booking cancelled.',
    );
  }

  Future<void> startService(String bookingId) async {
    await _runAction(
      () => _repository.startSession(bookingId),
      'Service started.',
    );
  }

  Future<void> finishService(String sessionId) async {
    await _runAction(
      () => _repository.finishSession(sessionId),
      'Service finished.',
    );
  }

  void clearMessages() {
    final current = state;
    if (current is HomeProviderBookingLoaded) {
      emit(current.copyWith(clearSuccess: true, clearError: true));
    }
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMsg,
  ) async {
    final current = state;
    if (current is! HomeProviderBookingLoaded) return;
    if (current.isPerformingAction) return;

    emit(current.copyWith(isPerformingAction: true));

    try {
      await action();
      final bookings = await _repository.getProviderBookings();
      emit(
        HomeProviderBookingLoaded(
          bookings: bookings,
          successMessage: successMsg,
        ),
      );
    } on HomeServiceBookingFailure catch (e) {
      emit(
        current.copyWith(isPerformingAction: false, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        current.copyWith(
          isPerformingAction: false,
          errorMessage: 'An unexpected error occurred.',
        ),
      );
    }
  }
}
