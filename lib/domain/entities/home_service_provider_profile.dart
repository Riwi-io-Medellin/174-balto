import 'package:equatable/equatable.dart';

enum HomeServiceProviderStatus { pending, approved, rejected, suspended }

class HomeServiceProviderProfile extends Equatable {
  const HomeServiceProviderProfile({
    required this.id,
    required this.userId,
    required this.status,
    this.isAcceptingBookings = false,
    this.baseLocation,
    this.experience,
    this.description,
    this.bio,
    this.yearsOfExperience,
    this.maxConcurrentBookings = 1,
    this.documentName,
    this.documentNumber,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final HomeServiceProviderStatus status;
  final bool isAcceptingBookings;
  final String? baseLocation;
  final String? experience;
  final String? description;
  final String? bio;
  final int? yearsOfExperience;
  final int maxConcurrentBookings;
  final String? documentName;
  final String? documentNumber;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    isAcceptingBookings,
    baseLocation,
    experience,
    description,
    bio,
    yearsOfExperience,
    maxConcurrentBookings,
    documentName,
    documentNumber,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  ];
}
