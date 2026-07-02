import '../entities/home_service_provider_profile.dart';

abstract class HomeServiceProfileRepository {
  /// Returns null when the user has not applied yet (backend 404).
  Future<HomeServiceProviderProfile?> getMyProfile();

  /// Register the current user as a home service provider (basic, no document).
  Future<HomeServiceProviderProfile> becomeProvider();

  /// Apply as a verified home service provider — upload identity document + profile info.
  Future<HomeServiceProviderProfile> apply({
    required String documentImagePath,
    required String baseLocation,
    required String experience,
    String? description,
  });

  /// Update the approved provider profile.
  Future<HomeServiceProviderProfile> updateMyProfile({
    String? bio,
    int? yearsOfExperience,
    bool? isAcceptingBookings,
    int? maxConcurrentBookings,
    String? baseLocation,
    double? latitude,
    double? longitude,
  });
}

class HomeServiceProfileFailure implements Exception {
  HomeServiceProfileFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeServiceProfileFailure($code): $message';
}
