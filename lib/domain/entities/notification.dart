import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.entityId,
    this.entityType,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String? entityId;
  final String? entityType;
  final bool isRead;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    body,
    entityId,
    entityType,
    isRead,
    createdAt,
  ];
}
