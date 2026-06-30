import '../entities/walker_profile.dart';

abstract class WalkerProfileRepository {
  /// Returns null when the user has not applied yet (backend 404).
  Future<WalkerProfile?> getMyProfile();

  /// Apply as a verified walker — upload identity document + profile info.
  Future<WalkerProfile> apply({
    required String documentImagePath,
    required String workLocation,
    required String experience,
    String? description,
  });

  /// Update the approved walker profile (bio, pricing, etc.).
  Future<WalkerProfile> updateMyProfile({
    String? bio,
    double? hourlyRate,
    double? serviceRadiusKm,
    int? yearsOfExperience,
    bool? isAcceptingBookings,
    double? workLatitude,
    double? workLongitude,
  });
}

class WalkerProfileFailure implements Exception {
  WalkerProfileFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'WalkerProfileFailure($code): $message';
}
