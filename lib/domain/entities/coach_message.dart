import 'package:equatable/equatable.dart';

enum CoachRole { user, assistant }

class CoachMessage extends Equatable {
  const CoachMessage({required this.role, required this.content});

  final CoachRole role;
  final String content;

  Map<String, dynamic> toJson() => {
        'role': role == CoachRole.user ? 'user' : 'assistant',
        'content': content,
      };

  factory CoachMessage.fromJson(Map<String, dynamic> json) => CoachMessage(
        role: json['role'] == 'user' ? CoachRole.user : CoachRole.assistant,
        content: json['content'] as String,
      );

  @override
  List<Object?> get props => [role, content];
}
