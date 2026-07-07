import '../../domain/entities/available_slot.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/entities/walker.dart';
import 'availability_slot_dto.dart';
import 'available_slot_dto.dart';

/// Maps backend WalkerSummaryResponse into a [Walker] entity.
class WalkerSummaryDto {
  WalkerSummaryDto({
    required this.id,
    required this.fullName,
    this.profilePhoto,
    this.bio,
    this.hourlyRate,
    required this.averageRating,
    required this.totalReviews,
    this.yearsOfExperience,
    this.serviceRadiusKm,
    required this.distanceKm,
    required this.hasAvailability,
    this.maxDogs,
  });

  factory WalkerSummaryDto.fromJson(Map<String, dynamic> json) {
    return WalkerSummaryDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      bio: json['bio'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      hasAvailability: json['hasAvailability'] as bool? ?? false,
      maxDogs: json['maxDogs'] as int?,
    );
  }

  final String id;
  final String fullName;
  final String? profilePhoto;
  final String? bio;
  final double? hourlyRate;
  final double averageRating;
  final int totalReviews;
  final int? yearsOfExperience;
  final double? serviceRadiusKm;
  final double distanceKm;
  final bool hasAvailability;
  final int? maxDogs;

  Walker toEntity() => Walker(
    id: id,
    name: fullName,
    rating: averageRating,
    reviews: totalReviews,
    description: bio ?? '',
    distance: distanceKm,
    imageUrl: profilePhoto ?? '',
    priceLabel: hourlyRate != null ? '\$${hourlyRate!.round()}/hr' : '',
    topRated: averageRating >= 4.8,
    isVerified: true,
    isAcceptingBookings: hasAvailability,
    yearsOfExperience: yearsOfExperience ?? 0,
    biography: bio,
    specialties: const [],
    galleryImages: const [],
    pricePerWalk: hourlyRate,
    serviceArea: '',
    maxDogs: maxDogs,
    completedWalks: null,
    avatarUrl: profilePhoto,
  );
}

/// Maps backend WalkerDetailResponse into a [Walker] entity.
class WalkerDetailDto {
  WalkerDetailDto({
    required this.id,
    required this.userId,
    required this.fullName,
    this.profilePhoto,
    this.bio,
    this.hourlyRate,
    this.serviceRadiusKm,
    this.yearsOfExperience,
    this.workLocation,
    required this.averageRating,
    required this.totalReviews,
    required this.completedWalks,
    this.maxDogs,
    this.weeklyAvailability = const [],
    this.availableSlots = const [],
  });

  factory WalkerDetailDto.fromJson(Map<String, dynamic> json) {
    final weekly = json['weeklyAvailability'];
    final slots = json['availableSlots'];
    return WalkerDetailDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      bio: json['bio'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toDouble(),
      yearsOfExperience: json['yearsOfExperience'] as int?,
      workLocation: json['workLocation'] as String?,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      completedWalks: json['completedWalks'] as int,
      maxDogs: json['maxDogs'] as int?,
      weeklyAvailability: weekly is List
          ? AvailabilitySlotDto.fromJsonList(
              weekly,
            ).map((d) => d.toEntity()).toList()
          : const [],
      availableSlots: slots is List
          ? AvailableSlotDto.listToEntities(slots)
          : const [],
    );
  }

  final String id;
  final String userId;
  final String fullName;
  final String? profilePhoto;
  final String? bio;
  final double? hourlyRate;
  final double? serviceRadiusKm;
  final int? yearsOfExperience;
  final String? workLocation;
  final double averageRating;
  final int totalReviews;
  final int completedWalks;
  final int? maxDogs;
  final List<AvailabilitySlot> weeklyAvailability;
  final List<AvailableSlot> availableSlots;

  Walker toEntity() => Walker(
    id: id,
    name: fullName,
    rating: averageRating,
    reviews: totalReviews,
    description: bio ?? '',
    distance: 0,
    imageUrl: profilePhoto ?? '',
    priceLabel: hourlyRate != null ? '\$${hourlyRate!.round()}/hr' : '',
    topRated: averageRating >= 4.8,
    isVerified: true,
    isAcceptingBookings: availableSlots.isNotEmpty,
    yearsOfExperience: yearsOfExperience ?? 0,
    biography: bio,
    specialties: const [],
    galleryImages: const [],
    pricePerWalk: hourlyRate,
    serviceArea: workLocation,
    serviceRadiusKm: serviceRadiusKm,
    maxDogs: maxDogs,
    completedWalks: completedWalks,
    avatarUrl: profilePhoto,
    weeklyAvailability: weeklyAvailability,
    availableSlots: availableSlots,
  );
}

/// Maps backend WalkerResponse (simple list format) into a [Walker] entity.
class WalkerListDto {
  WalkerListDto({
    required this.id,
    required this.userId,
    required this.fullName,
    this.profilePhoto,
    required this.verificationStatus,
    required this.available,
    this.workLocation,
    this.experience,
    this.description,
    required this.createdAt,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  factory WalkerListDto.fromJson(Map<String, dynamic> json) {
    return WalkerListDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String? ?? '',
      profilePhoto: json['profilePhoto'] as String?,
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      available: json['available'] as bool? ?? false,
      workLocation: json['workLocation'] as String?,
      experience: json['experience'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }

  final String id;
  final String userId;
  final String fullName;
  final String? profilePhoto;
  final String verificationStatus;
  final bool available;
  final String? workLocation;
  final String? experience;
  final String? description;
  final DateTime createdAt;
  final double averageRating;
  final int totalReviews;

  Walker toEntity() => Walker(
    id: id,
    name: fullName.isNotEmpty ? fullName : 'Walker',
    rating: averageRating,
    reviews: totalReviews,
    description: description ?? '',
    distance: 0,
    imageUrl: profilePhoto ?? '',
    priceLabel: '',
    topRated: false,
    isVerified: verificationStatus == 'approved',
    isAcceptingBookings: available,
    yearsOfExperience: 0,
    biography: description,
    specialties: const [],
    galleryImages: const [],
    pricePerWalk: null,
    serviceArea: workLocation,
    serviceRadiusKm: null,
    maxDogs: null,
    completedWalks: null,
    avatarUrl: profilePhoto,
  );
}
