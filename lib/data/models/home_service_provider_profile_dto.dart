import '../../domain/entities/home_service_provider_profile.dart';

class HomeServiceProviderProfileDto {
  HomeServiceProviderProfileDto({
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

  /// Parses the backend GET /home-services/providers/me response.
  factory HomeServiceProviderProfileDto.fromJson(Map<String, dynamic> json) {
    return HomeServiceProviderProfileDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: _parseStatus(json['verificationStatus'] as String? ?? ''),
      isAcceptingBookings: json['isAcceptingBookings'] as bool? ?? false,
      baseLocation: json['baseLocation'] as String?,
      experience: json['experience'] as String?,
      description: json['description'] as String?,
      bio: json['bio'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      maxConcurrentBookings: json['maxConcurrentBookings'] as int? ?? 1,
      documentName: json['documentName'] as String?,
      documentNumber: json['documentNumber'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates a DTO from the /apply response (HomeServiceApplyResponse).
  factory HomeServiceProviderProfileDto.fromApplyResponse(
      Map<String, dynamic> json) {
    return HomeServiceProviderProfileDto(
      id: json['providerId'] as String,
      userId: json['userId'] as String,
      status: _parseStatus(json['verificationStatus'] as String? ?? ''),
      documentName: json['documentName'] as String?,
      documentNumber: json['documentNumber'] as String?,
      createdAt: DateTime.now(),
    );
  }

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

  static HomeServiceProviderStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'approved':
        return HomeServiceProviderStatus.approved;
      case 'rejected':
        return HomeServiceProviderStatus.rejected;
      case 'suspended':
        return HomeServiceProviderStatus.suspended;
      default:
        return HomeServiceProviderStatus.pending;
    }
  }

  HomeServiceProviderProfile toEntity() => HomeServiceProviderProfile(
        id: id,
        userId: userId,
        status: status,
        isAcceptingBookings: isAcceptingBookings,
        baseLocation: baseLocation,
        experience: experience,
        description: description,
        bio: bio,
        yearsOfExperience: yearsOfExperience,
        maxConcurrentBookings: maxConcurrentBookings,
        documentName: documentName,
        documentNumber: documentNumber,
        latitude: latitude,
        longitude: longitude,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
