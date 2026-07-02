import 'package:dio/dio.dart';

import '../../domain/entities/home_provider_certification.dart';
import '../../domain/entities/home_provider_document.dart';
import '../../domain/entities/home_provider_gallery_photo.dart';
import '../../domain/entities/home_provider_specialty.dart';
import '../../domain/repositories/home_provider_assets_repository.dart';
import '../datasources/home_provider_assets_remote_datasource.dart';

class HomeProviderAssetsRepositoryImpl implements HomeProviderAssetsRepository {
  HomeProviderAssetsRepositoryImpl(this._remote);

  final HomeProviderAssetsRemoteDataSource _remote;

  @override
  Future<List<HomeProviderGalleryPhoto>> getGallery(String providerId) async {
    try {
      final dtos = await _remote.getGallery(providerId);
      return dtos.map((d) => d.toEntity()).toList();
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<HomeProviderGalleryPhoto> addMyPhoto(String photoUrl) async {
    try {
      final dto = await _remote.addMyPhoto(photoUrl);
      return dto.toEntity();
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<void> deleteMyPhoto(String photoId) async {
    try {
      await _remote.deleteMyPhoto(photoId);
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<List<HomeProviderDocument>> getDocuments(String providerId) async {
    try {
      final dtos = await _remote.getDocuments(providerId);
      return dtos.map((d) => d.toEntity()).toList();
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<HomeProviderDocument> addMyDocument({
    required String documentType,
    required String fileUrl,
  }) async {
    try {
      final dto = await _remote.addMyDocument(
          documentType: documentType, fileUrl: fileUrl);
      return dto.toEntity();
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<void> deleteMyDocument(String documentId) async {
    try {
      await _remote.deleteMyDocument(documentId);
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<List<HomeProviderCertification>> getCertifications(
      String providerId) async {
    try {
      final dtos = await _remote.getCertifications(providerId);
      return dtos.map((d) => d.toEntity()).toList();
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<HomeProviderCertification> addMyCertification({
    String? serviceTypeId,
    required String title,
    String? issuingOrganization,
    String? credentialNumber,
    String? issuedDate,
    String? expiryDate,
    String? documentUrl,
  }) async {
    try {
      final dto = await _remote.addMyCertification(
        serviceTypeId: serviceTypeId,
        title: title,
        issuingOrganization: issuingOrganization,
        credentialNumber: credentialNumber,
        issuedDate: issuedDate,
        expiryDate: expiryDate,
        documentUrl: documentUrl,
      );
      return dto.toEntity();
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<void> deleteMyCertification(String certificationId) async {
    try {
      await _remote.deleteMyCertification(certificationId);
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<List<HomeProviderSpecialty>> getSpecialties(String providerId) async {
    try {
      final dtos = await _remote.getSpecialties(providerId);
      return dtos.map((d) => d.toEntity()).toList();
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<HomeProviderSpecialty> addMySpecialty(String specialty) async {
    try {
      final dto = await _remote.addMySpecialty(specialty);
      return dto.toEntity();
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }

  @override
  Future<void> deleteMySpecialty(String specialtyId) async {
    try {
      await _remote.deleteMySpecialty(specialtyId);
    } on HomeProviderAssetsFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeProviderAssetsFailure(
          'NETWORK_ERROR', e.message ?? 'Could not reach the server.');
    }
  }
}
