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

  /// Update the current user's approved business.
  Future<Business> updateMyBusiness({
    String? instagramUrl,
    String? facebookUrl,
    String? description,
    String? photoUrl,
    bool? sellsServices,
    bool? sellsProducts,
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

  /// Services/products for a given business (public, read-only).
  Future<List<BusinessServiceItem>> getBusinessServices(String businessId);

  /// Day-specific exceptions for a given business (public, read-only).
  Future<List<BusinessHourException>> getBusinessHourExceptions(
    String businessId,
  );

  /// Replace the current user's business weekly hours.
  Future<List<BusinessHour>> updateMyHours(List<BusinessHour> hours);

  /// Upload a NIT/verification document for a business the user owns.
  /// Also used for gallery photos with documentType = 'gallery'.
  Future<void> addBusinessDocument({
    required String businessId,
    required String documentType,
    required String fileUrl,
  });

  /// All documents/photos for a business (includes gallery photos).
  Future<List<BusinessDocumentItem>> getBusinessDocuments(String businessId);

  /// Picks up an already-uploaded image URL and registers it as a gallery
  /// photo in one call (upload + register). Convenience over
  /// [addBusinessDocument] for the edit-profile gallery UI.
  Future<void> addGalleryPhoto({
    required String businessId,
    required String imagePath,
  });

  /// Delete a document/gallery photo the user's business owns.
  Future<void> deleteBusinessDocument({
    required String businessId,
    required String documentId,
  });

  /// Add a Market item (service or product) to a business the user owns.
  Future<BusinessServiceItem> createBusinessService({
    required String businessId,
    required String serviceType,
    required double price,
    String? description,
    String? photoUrl,
    String itemKind = 'service',
  });

  /// Update a Market item (service or product).
  Future<BusinessServiceItem> updateBusinessService({
    required String businessId,
    required String serviceId,
    required String serviceType,
    required double price,
    String? description,
    String? photoUrl,
    String itemKind = 'service',
  });

  /// Delete a Market item (service or product).
  Future<void> deleteBusinessService({
    required String businessId,
    required String serviceId,
  });
}

class BusinessFailure implements Exception {
  BusinessFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'BusinessFailure($code): $message';
}
