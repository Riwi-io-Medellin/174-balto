import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.walkSessionId,
    required this.senderUserId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String walkSessionId;
  final String senderUserId;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, walkSessionId, senderUserId, text, createdAt];
}
