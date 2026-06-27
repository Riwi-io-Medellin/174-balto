import 'package:equatable/equatable.dart';

class Walker extends Equatable {
  const Walker({
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

  @override
  List<Object?> get props => [
        id,
        userId,
        verificationStatus,
        available,
        workLocation,
        experience,
        description,
        createdAt,
      ];
}
