import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/feedback_summary.dart';
import '../../../domain/repositories/feedback_repository.dart';
import 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit(this._repository) : super(const FeedbackInitial());

  final FeedbackRepository _repository;

  Future<void> loadWalkerReviews(String walkerId) async {
    emit(const FeedbackLoading());
    try {
      final summary = await _repository.getByWalker(walkerId);
      emit(FeedbackLoaded(
        summary ?? FeedbackSummary(
          targetId: walkerId,
          targetType: 'walker',
          averageRating: 0,
          totalReviews: 0,
        ),
      ));
    } on FeedbackFailure catch (e) {
      emit(FeedbackError(e.message));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> loadBusinessReviews(String businessId) async {
    emit(const FeedbackLoading());
    try {
      final summary = await _repository.getByBusiness(businessId);
      emit(FeedbackLoaded(
        summary ?? FeedbackSummary(
          targetId: businessId,
          targetType: 'business',
          averageRating: 0,
          totalReviews: 0,
        ),
      ));
    } on FeedbackFailure catch (e) {
      emit(FeedbackError(e.message));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> createWalkerReview({
    required String walkerId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _repository.createWalkerReview(
        walkerId: walkerId,
        rating: rating,
        comment: comment,
      );
      await loadWalkerReviews(walkerId);
    } on FeedbackFailure catch (e) {
      emit(FeedbackError(e.message));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> createBusinessReview({
    required String businessId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _repository.createBusinessReview(
        businessId: businessId,
        rating: rating,
        comment: comment,
      );
      await loadBusinessReviews(businessId);
    } on FeedbackFailure catch (e) {
      emit(FeedbackError(e.message));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }
}
