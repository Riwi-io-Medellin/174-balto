import 'package:equatable/equatable.dart';

import 'availability_slot.dart';
import 'available_slot.dart';
import 'home_provider_service_area.dart';
import 'home_provider_service_item.dart';

class HomeServiceProvider extends Equatable {
  const HomeServiceProvider({
    this.id = '',
    required this.name,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.distance,
    required this.imageUrl,
    this.isVerified = false,
    this.isAcceptingBookings = false,
    this.yearsOfExperience = 0,
    this.biography,
    this.specialties = const [],
    this.galleryImages = const [],
    this.baseLocation,
    this.completedBookings,
    this.avatarUrl,
    this.services = const [],
    this.serviceAreas = const [],
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
  final bool isVerified;
  final bool isAcceptingBookings;
  final int yearsOfExperience;
  final String? biography;
  final List<String> specialties;
  final List<String> galleryImages;
  final String? baseLocation;
  final int? completedBookings;
  final String? avatarUrl;
  final List<HomeProviderServiceItem> services;
  final List<HomeProviderServiceArea> serviceAreas;
  final List<AvailabilitySlot> weeklyAvailability;
  final List<AvailableSlot> availableSlots;

  /// Lowest active offered-service price, for card display (e.g. "From $30").
  String get startingPriceLabel {
    final active = services.where((s) => s.isActive && s.price != null);
    if (active.isEmpty) return 'Ask for price';
    final lowest = active.map((s) => s.price!).reduce((a, b) => a < b ? a : b);
    return 'From \$${lowest.toStringAsFixed(0)}';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    rating,
    reviews,
    description,
    distance,
    imageUrl,
    isVerified,
    isAcceptingBookings,
    yearsOfExperience,
    biography,
    specialties,
    galleryImages,
    baseLocation,
    completedBookings,
    avatarUrl,
    services,
    serviceAreas,
    weeklyAvailability,
    availableSlots,
  ];
}
