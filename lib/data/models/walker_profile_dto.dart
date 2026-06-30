import '../../domain/entities/walker_profile.dart';

class WalkerProfileDto {
  WalkerProfileDto({
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
    this.maxDogs,
    this.documentName,
    this.documentNumber,
    this.workLatitude,
    this.workLongitude,
    required this.createdAt,
    this.updatedAt,
  });

  /// Parses the backend GET /walkers/me response (WalkerProfileResponse).
  factory WalkerProfileDto.fromJson(Map<String, dynamic> json) {
    return WalkerProfileDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: _parseStatus(json['verificationStatus'] as String? ?? ''),
      available: json['available'] as bool? ?? false,
      workLocation: json['workLocation'] as String?,
      experience: json['experience'] as String?,
      description: json['description'] as String?,
      bio: json['bio'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toDouble(),
      yearsOfExperience: json['yearsOfExperience'] as int?,
      isAcceptingBookings: json['isAcceptingBookings'] as bool? ?? false,
      maxDogs: json['maxDogs'] as int?,
      documentName: json['documentName'] as String?,
      documentNumber: json['documentNumber'] as String?,
      workLatitude: (json['workLatitude'] as num?)?.toDouble(),
      workLongitude: (json['workLongitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates a DTO from the apply response (WalkerApplyResponse).
  factory WalkerProfileDto.fromApplyResponse(Map<String, dynamic> json) {
    return WalkerProfileDto(
      id: json['walkerId'] as String,
      userId: json['userId'] as String,
      status: _parseStatus(json['verificationStatus'] as String? ?? ''),
      documentName: json['documentName'] as String?,
      documentNumber: json['documentNumber'] as String?,
      createdAt: DateTime.now(),
    );
  }

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
  final int? maxDogs;
  final String? documentName;
  final String? documentNumber;
  final double? workLatitude;
  final double? workLongitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  static WalkerStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'approved':
        return WalkerStatus.approved;
      case 'rejected':
        return WalkerStatus.rejected;
      default:
        return WalkerStatus.pending;
    }
  }

  WalkerProfile toEntity() => WalkerProfile(
        id: id,
        userId: userId,
        status: status,
        available: available,
        workLocation: workLocation,
        experience: experience,
        description: description,
        bio: bio,
        hourlyRate: hourlyRate,
        serviceRadiusKm: serviceRadiusKm,
        yearsOfExperience: yearsOfExperience,
        isAcceptingBookings: isAcceptingBookings,
        maxDogs: maxDogs,
        documentName: documentName,
        documentNumber: documentNumber,
        workLatitude: workLatitude,
        workLongitude: workLongitude,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
