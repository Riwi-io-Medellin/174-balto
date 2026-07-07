import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_message.dart';

abstract class WalkChatState extends Equatable {
  const WalkChatState();

  @override
  List<Object?> get props => const [];
}

class WalkChatInitial extends WalkChatState {
  const WalkChatInitial();
}

class WalkChatLoaded extends WalkChatState {
  const WalkChatLoaded({
    required this.currentUserId,
    this.messages = const [],
    this.sendError,
  });

  final String currentUserId;
  final List<ChatMessage> messages;
  final String? sendError;

  WalkChatLoaded copyWith({List<ChatMessage>? messages, String? sendError}) =>
      WalkChatLoaded(
        currentUserId: currentUserId,
        messages: messages ?? this.messages,
        sendError: sendError,
      );

  @override
  List<Object?> get props => [currentUserId, messages, sendError];
}

class WalkChatError extends WalkChatState {
  const WalkChatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
