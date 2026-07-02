import '../entities/home_provider_certification.dart';
import '../entities/home_provider_document.dart';
import '../entities/home_provider_gallery_photo.dart';
import '../entities/home_provider_specialty.dart';

abstract class HomeProviderAssetsRepository {
  Future<List<HomeProviderGalleryPhoto>> getGallery(String providerId);
  Future<HomeProviderGalleryPhoto> addMyPhoto(String photoUrl);
  Future<void> deleteMyPhoto(String photoId);

  Future<List<HomeProviderDocument>> getDocuments(String providerId);
  Future<HomeProviderDocument> addMyDocument({
    required String documentType,
    required String fileUrl,
  });
  Future<void> deleteMyDocument(String documentId);

  Future<List<HomeProviderCertification>> getCertifications(String providerId);
  Future<HomeProviderCertification> addMyCertification({
    String? serviceTypeId,
    required String title,
    String? issuingOrganization,
    String? credentialNumber,
    String? issuedDate,
    String? expiryDate,
    String? documentUrl,
  });
  Future<void> deleteMyCertification(String certificationId);

  Future<List<HomeProviderSpecialty>> getSpecialties(String providerId);
  Future<HomeProviderSpecialty> addMySpecialty(String specialty);
  Future<void> deleteMySpecialty(String specialtyId);
}

class HomeProviderAssetsFailure implements Exception {
  HomeProviderAssetsFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeProviderAssetsFailure($code): $message';
}
