import '../entities/business.dart';
import '../entities/business_hour_exception.dart';

abstract class BusinessRepository {
  /// List all businesses with optional filters.
  Future<List<Business>> getBusinesses({String? type, String? location});

  /// Get full business detail by ID.
  Future<Business> getBusinessDetail(String businessId);

  /// Create a new business for the current user.
  Future<Business> createBusiness({
    required String name,
    required String nit,
    required String email,
    required String phone,
    String? type,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
  });

  /// Get the current user's own business, if they have one.
  /// Returns null when the user has never registered a business.
  Future<Business?> getMyBusiness();

  /// Update the current user's approved business (Instagram/Facebook only).
  Future<Business> updateMyBusiness({
    String? instagramUrl,
    String? facebookUrl,
  });

  /// Registers a new business for the current user and attaches the NIT
  /// document (upload it first via UploadRepository to get [documentPath]).
  Future<Business> apply({
    required String name,
    required String nit,
    required String email,
    required String phone,
    required String documentImagePath,
    String? type,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
  });

  /// Weekly opening hours for a given business (public, read-only).
  Future<List<BusinessHour>> getBusinessHours(String businessId);

  /// Day-specific exceptions for a given business (public, read-only).
  Future<List<BusinessHourException>> getBusinessHourExceptions(
    String businessId,
  );

  /// Replace the current user's business weekly hours.
  Future<List<BusinessHour>> updateMyHours(List<BusinessHour> hours);

  /// Upload a NIT/verification document for a business the user owns.
  Future<void> addBusinessDocument({
    required String businessId,
    required String documentType,
    required String fileUrl,
  });
}

class BusinessFailure implements Exception {
  BusinessFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'BusinessFailure($code): $message';
}
