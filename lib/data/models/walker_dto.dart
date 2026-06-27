import '../../domain/entities/walker.dart';

class WalkerDto {
  WalkerDto({
    required this.id,
    required this.userId,
    required this.verificationStatus,
    required this.available,
    this.workLocation,
    this.experience,
    this.description,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String verificationStatus;
  final bool available;
  final String? workLocation;
  final String? experience;
  final String? description;
  final DateTime createdAt;

  factory WalkerDto.fromJson(Map<String, dynamic> json) {
    return WalkerDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      verificationStatus: json['verificationStatus'] as String,
      available: json['available'] as bool,
      workLocation: json['workLocation'] as String?,
      experience: json['experience'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Walker toEntity() => Walker(
        id: id,
        userId: userId,
        verificationStatus: verificationStatus,
        available: available,
        workLocation: workLocation,
        experience: experience,
        description: description,
        createdAt: createdAt,
      );
}
