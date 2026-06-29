import 'package:equatable/equatable.dart';

enum WalkerStatus { pending, approved, rejected }

class WalkerProfile extends Equatable {
  const WalkerProfile({
    required this.id,
    required this.userId,
    required this.status,
    this.available = false,
    this.workLocation,
    this.experience,
    this.description,
    this.bio,
    this.hourlyRate,
    this.serviceRadiusKm,
    this.yearsOfExperience,
    this.isAcceptingBookings = false,
    this.documentName,
    this.documentNumber,
    this.workLatitude,
    this.workLongitude,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final WalkerStatus status;
  final bool available;
  final String? workLocation;
  final String? experience;
  final String? description;
  final String? bio;
  final double? hourlyRate;
  final double? serviceRadiusKm;
  final int? yearsOfExperience;
  final bool isAcceptingBookings;
  final String? documentName;
  final String? documentNumber;
  final double? workLatitude;
  final double? workLongitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        available,
        workLocation,
        experience,
        description,
        bio,
        hourlyRate,
        serviceRadiusKm,
        yearsOfExperience,
        isAcceptingBookings,
        documentName,
        documentNumber,
        workLatitude,
        workLongitude,
        createdAt,
        updatedAt,
      ];
}
