import 'package:equatable/equatable.dart';

import '../../../domain/entities/feedback_summary.dart';

abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => const [];
}

class FeedbackInitial extends FeedbackState {
  const FeedbackInitial();
}

class FeedbackLoading extends FeedbackState {
  const FeedbackLoading();
}

class FeedbackLoaded extends FeedbackState {
  const FeedbackLoaded(this.summary);

  final FeedbackSummary summary;

  @override
  List<Object?> get props => [summary];
}

class FeedbackError extends FeedbackState {
  const FeedbackError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
