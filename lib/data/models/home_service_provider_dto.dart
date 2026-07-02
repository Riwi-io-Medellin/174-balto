import '../../domain/entities/availability_slot.dart';
import '../../domain/entities/available_slot.dart';
import '../../domain/entities/home_service_provider.dart';
import 'availability_slot_dto.dart';
import 'available_slot_dto.dart';
import 'home_provider_service_area_dto.dart';
import 'home_provider_service_dto.dart';

/// Maps backend HomeServiceProviderSummaryResponse into a [HomeServiceProvider].
class HomeServiceProviderSummaryDto {
  HomeServiceProviderSummaryDto({
    required this.id,
    required this.fullName,
    this.profilePhoto,
    this.bio,
    required this.averageRating,
    required this.totalReviews,
    this.yearsOfExperience,
    required this.distanceKm,
    required this.hasAvailability,
    this.services = const [],
  });

  factory HomeServiceProviderSummaryDto.fromJson(Map<String, dynamic> json) {
    final servicesJson = json['services'] as List<dynamic>?;
    return HomeServiceProviderSummaryDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      bio: json['bio'] as String?,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      hasAvailability: json['hasAvailability'] as bool? ?? false,
      services: servicesJson == null
          ? const []
          : servicesJson
              .map((e) =>
                  HomeProviderServiceDto.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  final String id;
  final String fullName;
  final String? profilePhoto;
  final String? bio;
  final double averageRating;
  final int totalReviews;
  final int? yearsOfExperience;
  final double distanceKm;
  final bool hasAvailability;
  final List<HomeProviderServiceDto> services;

  HomeServiceProvider toEntity() => HomeServiceProvider(
        id: id,
        name: fullName,
        rating: averageRating,
        reviews: totalReviews,
        description: bio ?? '',
        distance: distanceKm,
        imageUrl: profilePhoto ?? '',
        isVerified: true,
        isAcceptingBookings: hasAvailability,
        yearsOfExperience: yearsOfExperience ?? 0,
        biography: bio,
        avatarUrl: profilePhoto,
        services: services.map((s) => s.toEntity()).toList(),
      );
}

/// Maps backend HomeServiceProviderDetailResponse into a [HomeServiceProvider].
class HomeServiceProviderDetailDto {
  HomeServiceProviderDetailDto({
    required this.id,
    required this.userId,
    required this.fullName,
    this.profilePhoto,
    this.bio,
    this.yearsOfExperience,
    this.baseLocation,
    required this.averageRating,
    required this.totalReviews,
    required this.completedBookings,
    this.services = const [],
    this.specialties = const [],
    this.serviceAreas = const [],
    this.weeklyAvailability = const [],
    this.availableSlots = const [],
  });

  factory HomeServiceProviderDetailDto.fromJson(Map<String, dynamic> json) {
    final services = json['services'] as List<dynamic>?;
    final specialties = json['specialties'] as List<dynamic>?;
    final serviceAreas = json['serviceAreas'] as List<dynamic>?;
    final weekly = json['weeklyAvailability'];
    final slots = json['availableSlots'];
    return HomeServiceProviderDetailDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      bio: json['bio'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      baseLocation: json['baseLocation'] as String?,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      completedBookings: json['completedBookings'] as int,
      services: services == null
          ? const []
          : services
              .map((e) =>
                  HomeProviderServiceDto.fromJson(e as Map<String, dynamic>))
              .toList(),
      specialties: specialties == null
          ? const []
          : specialties
              .map((e) => (e as Map<String, dynamic>)['specialty'] as String)
              .toList(),
      serviceAreas: serviceAreas == null
          ? const []
          : HomeProviderServiceAreaDto.fromJsonList(serviceAreas),
      weeklyAvailability: weekly is List
          ? AvailabilitySlotDto.fromJsonList(weekly)
              .map((d) => d.toEntity())
              .toList()
          : const [],
      availableSlots:
          slots is List ? AvailableSlotDto.listToEntities(slots) : const [],
    );
  }

  final String id;
  final String userId;
  final String fullName;
  final String? profilePhoto;
  final String? bio;
  final int? yearsOfExperience;
  final String? baseLocation;
  final double averageRating;
  final int totalReviews;
  final int completedBookings;
  final List<HomeProviderServiceDto> services;
  final List<String> specialties;
  final List<HomeProviderServiceAreaDto> serviceAreas;
  final List<AvailabilitySlot> weeklyAvailability;
  final List<AvailableSlot> availableSlots;

  HomeServiceProvider toEntity() => HomeServiceProvider(
        id: id,
        name: fullName,
        rating: averageRating,
        reviews: totalReviews,
        description: bio ?? '',
        distance: 0,
        imageUrl: profilePhoto ?? '',
        isVerified: true,
        isAcceptingBookings: availableSlots.isNotEmpty,
        yearsOfExperience: yearsOfExperience ?? 0,
        biography: bio,
        specialties: specialties,
        baseLocation: baseLocation,
        completedBookings: completedBookings,
        avatarUrl: profilePhoto,
        services: services.map((s) => s.toEntity()).toList(),
        serviceAreas:
            serviceAreas.map((a) => a.toEntity()).toList(growable: false),
        weeklyAvailability: weeklyAvailability,
        availableSlots: availableSlots,
      );
}

/// Maps backend HomeServiceProviderResponse (simple list format) into a [HomeServiceProvider].
class HomeServiceProviderListDto {
  HomeServiceProviderListDto({
    required this.id,
    required this.userId,
    required this.fullName,
    this.profilePhoto,
    required this.verificationStatus,
    required this.isAcceptingBookings,
    this.baseLocation,
    this.experience,
    this.description,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  factory HomeServiceProviderListDto.fromJson(Map<String, dynamic> json) {
    return HomeServiceProviderListDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String? ?? '',
      profilePhoto: json['profilePhoto'] as String?,
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      isAcceptingBookings: json['isAcceptingBookings'] as bool? ?? false,
      baseLocation: json['baseLocation'] as String?,
      experience: json['experience'] as String?,
      description: json['description'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }

  final String id;
  final String userId;
  final String fullName;
  final String? profilePhoto;
  final String verificationStatus;
  final bool isAcceptingBookings;
  final String? baseLocation;
  final String? experience;
  final String? description;
  final double averageRating;
  final int totalReviews;

  HomeServiceProvider toEntity() => HomeServiceProvider(
        id: id,
        name: fullName.isNotEmpty ? fullName : 'Provider',
        rating: averageRating,
        reviews: totalReviews,
        description: description ?? '',
        distance: 0,
        imageUrl: profilePhoto ?? '',
        isVerified: verificationStatus == 'approved',
        isAcceptingBookings: isAcceptingBookings,
        biography: description,
        baseLocation: baseLocation,
        avatarUrl: profilePhoto,
      );
}
