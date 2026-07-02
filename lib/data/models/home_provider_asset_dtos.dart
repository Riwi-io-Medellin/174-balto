import '../../domain/entities/home_provider_certification.dart';
import '../../domain/entities/home_provider_document.dart';
import '../../domain/entities/home_provider_gallery_photo.dart';
import '../../domain/entities/home_provider_specialty.dart';

class HomeProviderGalleryPhotoDto {
  const HomeProviderGalleryPhotoDto({required this.id, required this.photoUrl});

  factory HomeProviderGalleryPhotoDto.fromJson(Map<String, dynamic> json) =>
      HomeProviderGalleryPhotoDto(
        id: json['id'] as String,
        photoUrl: json['photoUrl'] as String,
      );

  final String id;
  final String photoUrl;

  HomeProviderGalleryPhoto toEntity() =>
      HomeProviderGalleryPhoto(id: id, photoUrl: photoUrl);
}

class HomeProviderDocumentDto {
  const HomeProviderDocumentDto({
    required this.id,
    required this.documentType,
    required this.fileUrl,
  });

  factory HomeProviderDocumentDto.fromJson(Map<String, dynamic> json) =>
      HomeProviderDocumentDto(
        id: json['id'] as String,
        documentType: json['documentType'] as String,
        fileUrl: json['fileUrl'] as String,
      );

  final String id;
  final String documentType;
  final String fileUrl;

  HomeProviderDocument toEntity() =>
      HomeProviderDocument(id: id, documentType: documentType, fileUrl: fileUrl);
}

class HomeProviderCertificationDto {
  const HomeProviderCertificationDto({
    required this.id,
    required this.title,
    this.issuingOrganization,
    this.credentialNumber,
    this.issuedDate,
    this.expiryDate,
    this.documentUrl,
  });

  factory HomeProviderCertificationDto.fromJson(Map<String, dynamic> json) =>
      HomeProviderCertificationDto(
        id: json['id'] as String,
        title: json['title'] as String,
        issuingOrganization: json['issuingOrganization'] as String?,
        credentialNumber: json['credentialNumber'] as String?,
        issuedDate: json['issuedDate'] as String?,
        expiryDate: json['expiryDate'] as String?,
        documentUrl: json['documentUrl'] as String?,
      );

  final String id;
  final String title;
  final String? issuingOrganization;
  final String? credentialNumber;
  final String? issuedDate;
  final String? expiryDate;
  final String? documentUrl;

  HomeProviderCertification toEntity() => HomeProviderCertification(
        id: id,
        title: title,
        issuingOrganization: issuingOrganization,
        credentialNumber: credentialNumber,
        issuedDate: issuedDate,
        expiryDate: expiryDate,
        documentUrl: documentUrl,
      );
}

class HomeProviderSpecialtyDto {
  const HomeProviderSpecialtyDto({required this.id, required this.specialty});

  factory HomeProviderSpecialtyDto.fromJson(Map<String, dynamic> json) =>
      HomeProviderSpecialtyDto(
        id: json['id'] as String,
        specialty: json['specialty'] as String,
      );

  final String id;
  final String specialty;

  HomeProviderSpecialty toEntity() =>
      HomeProviderSpecialty(id: id, specialty: specialty);
}
