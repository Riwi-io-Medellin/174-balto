import 'package:equatable/equatable.dart';

import 'availability_slot.dart';
import 'available_slot.dart';

class Walker extends Equatable {
  const Walker({
    this.id = '',
    required this.name,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.distance,
    required this.imageUrl,
    required this.priceLabel,
    this.topRated = false,
    this.isVerified = false,
    this.isAcceptingBookings = false,
    this.yearsOfExperience = 0,
    this.biography,
    this.specialties = const [],
    this.galleryImages = const [],
    this.pricePerWalk,
    this.serviceArea,
    this.serviceRadiusKm,
    this.maxDogs,
    this.completedWalks,
    this.avatarUrl,
    this.weeklyAvailability = const [],
    this.availableSlots = const [],
  });

  final String id;
  final String name;
  final double rating;
  final int reviews;
  final String description;
  final double distance;
  final String imageUrl;
  final String priceLabel;
  final bool topRated;
  final bool isVerified;
  final bool isAcceptingBookings;
  final int yearsOfExperience;
  final String? biography;
  final List<String> specialties;
  final List<String> galleryImages;
  final double? pricePerWalk;
  final String? serviceArea;
  final double? serviceRadiusKm;
  final int? maxDogs;
  final int? completedWalks;
  final String? avatarUrl;
  final List<AvailabilitySlot> weeklyAvailability;
  final List<AvailableSlot> availableSlots;

  @override
  List<Object?> get props => [
    id,
    name,
    rating,
    reviews,
    description,
    distance,
    imageUrl,
    priceLabel,
    topRated,
    isVerified,
    isAcceptingBookings,
    yearsOfExperience,
    biography,
    specialties,
    galleryImages,
    pricePerWalk,
    serviceArea,
    serviceRadiusKm,
    maxDogs,
    completedWalks,
    avatarUrl,
    weeklyAvailability,
    availableSlots,
  ];
}
