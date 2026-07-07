import '../../domain/entities/notification.dart';

class AppNotificationDto {
  AppNotificationDto({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.entityId,
    this.entityType,
    this.metadata,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? entityId;
  final String? entityType;
  final String? metadata;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  factory AppNotificationDto.fromJson(Map<String, dynamic> json) {
    return AppNotificationDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      entityId: json['entityId'] as String?,
      entityType: json['entityType'] as String?,
      metadata: json['metadata'] as String?,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  AppNotification toEntity() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    entityId: entityId,
    entityType: entityType,
    isRead: isRead,
    createdAt: createdAt,
  );
}
