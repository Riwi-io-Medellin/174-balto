import 'package:equatable/equatable.dart';

import '../../../domain/entities/coach_message.dart';

abstract class CoachState extends Equatable {
  const CoachState();

  @override
  List<Object?> get props => const [];
}

class CoachInitial extends CoachState {
  const CoachInitial();
}

class CoachLoaded extends CoachState {
  const CoachLoaded({
    this.messages = const [],
    this.isTyping = false,
    this.sendError,
  });

  final List<CoachMessage> messages;
  final bool isTyping;
  final String? sendError;

  CoachLoaded copyWith({
    List<CoachMessage>? messages,
    bool? isTyping,
    String? sendError,
  }) =>
      CoachLoaded(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        sendError: sendError,
      );

  @override
  List<Object?> get props => [messages, isTyping, sendError];
}
