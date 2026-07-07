import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/walk_booking_repository.dart';
import 'my_walks_state.dart';

class MyWalksCubit extends Cubit<MyWalksState> {
  MyWalksCubit(this._repository) : super(const MyWalksInitial());

  final WalkBookingRepository _repository;

  bool _isRefreshing = false;

  Future<void> load() async {
    emit(const MyWalksLoading());
    try {
      final bookings = await _repository.getMyBookings();
      emit(MyWalksLoaded(bookings: bookings));
    } on WalkBookingFailure catch (e) {
      emit(MyWalksLoaded(bookings: const [], errorMessage: e.message));
    } catch (_) {
      emit(
        const MyWalksLoaded(
          bookings: [],
          errorMessage: 'Could not load walks.',
        ),
      );
    }
  }

  Future<void> refresh() async {
    // Guards against overlapping calls from the three independent triggers
    // that can fire refresh() (30s poll timer, app-resume, pull-to-refresh).
    if (_isRefreshing) return;
    _isRefreshing = true;
    final current = state;
    try {
      final bookings = await _repository.getMyBookings();
      emit(MyWalksLoaded(bookings: bookings));
    } on WalkBookingFailure catch (e) {
      if (current is MyWalksLoaded) {
        emit(current.copyWith(errorMessage: e.message));
      } else {
        emit(MyWalksLoaded(bookings: const [], errorMessage: e.message));
      }
    } catch (_) {
      if (current is MyWalksLoaded) {
        emit(current.copyWith(errorMessage: 'Could not refresh walks.'));
      } else {
        emit(
          const MyWalksLoaded(
            bookings: [],
            errorMessage: 'Could not refresh walks.',
          ),
        );
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final current = state;
    if (current is! MyWalksLoaded || current.isPerformingAction) return;
    emit(current.copyWith(isPerformingAction: true));
    try {
      await _repository.cancelBooking(bookingId);
      final bookings = await _repository.getMyBookings();
      emit(
        MyWalksLoaded(bookings: bookings, successMessage: 'Booking cancelled.'),
      );
    } on WalkBookingFailure catch (e) {
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

  void clearMessages() {
    final current = state;
    if (current is MyWalksLoaded) {
      emit(current.copyWith(clearSuccess: true, clearError: true));
    }
  }
}
