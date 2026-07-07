import 'package:dio/dio.dart';

import '../../domain/repositories/home_provider_assets_repository.dart';
import '../models/home_provider_asset_dtos.dart';

class HomeProviderAssetsRemoteDataSource {
  HomeProviderAssetsRemoteDataSource(this._dio);

  final Dio _dio;

  // ── Gallery ──────────────────────────────────────────────────────────────

  Future<List<HomeProviderGalleryPhotoDto>> getGallery(
    String providerId,
  ) async {
    final response = await _dio.get<dynamic>(
      '/home-services/providers/$providerId/gallery',
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map(
            (e) =>
                HomeProviderGalleryPhotoDto.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    _throwFailure(status, data, 'FETCH_FAILED');
  }

  Future<HomeProviderGalleryPhotoDto> addMyPhoto(String photoUrl) async {
    final response = await _dio.post<dynamic>(
      '/home-services/providers/me/gallery',
      data: {'photoUrl': photoUrl},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return HomeProviderGalleryPhotoDto.fromJson(data);
    }
    _throwFailure(status, data, 'ADD_FAILED');
  }

  Future<void> deleteMyPhoto(String photoId) async {
    final response = await _dio.delete<dynamic>(
      '/home-services/providers/me/gallery/$photoId',
    );
    final status = response.statusCode ?? 0;
    if (status == 204 || status == 200) return;
    _throwFailure(status, response.data, 'DELETE_FAILED');
  }

  // ── Documents ────────────────────────────────────────────────────────────

  Future<List<HomeProviderDocumentDto>> getDocuments(String providerId) async {
    final response = await _dio.get<dynamic>(
      '/home-services/providers/$providerId/documents',
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map(
            (e) => HomeProviderDocumentDto.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    _throwFailure(status, data, 'FETCH_FAILED');
  }

  Future<HomeProviderDocumentDto> addMyDocument({
    required String documentType,
    required String fileUrl,
  }) async {
    final response = await _dio.post<dynamic>(
      '/home-services/providers/me/documents',
      data: {'documentType': documentType, 'fileUrl': fileUrl},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return HomeProviderDocumentDto.fromJson(data);
    }
    _throwFailure(status, data, 'ADD_FAILED');
  }

  Future<void> deleteMyDocument(String documentId) async {
    final response = await _dio.delete<dynamic>(
      '/home-services/providers/me/documents/$documentId',
    );
    final status = response.statusCode ?? 0;
    if (status == 204 || status == 200) return;
    _throwFailure(status, response.data, 'DELETE_FAILED');
  }

  // ── Certifications ───────────────────────────────────────────────────────

  Future<List<HomeProviderCertificationDto>> getCertifications(
    String providerId,
  ) async {
    final response = await _dio.get<dynamic>(
      '/home-services/providers/$providerId/certifications',
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map(
            (e) => HomeProviderCertificationDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    _throwFailure(status, data, 'FETCH_FAILED');
  }

  Future<HomeProviderCertificationDto> addMyCertification({
    String? serviceTypeId,
    required String title,
    String? issuingOrganization,
    String? credentialNumber,
    String? issuedDate,
    String? expiryDate,
    String? documentUrl,
  }) async {
    final response = await _dio.post<dynamic>(
      '/home-services/providers/me/certifications',
      data: {
        'serviceTypeId': serviceTypeId,
        'title': title,
        'issuingOrganization': issuingOrganization,
        'credentialNumber': credentialNumber,
        'issuedDate': issuedDate,
        'expiryDate': expiryDate,
        'documentUrl': documentUrl,
      },
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return HomeProviderCertificationDto.fromJson(data);
    }
    _throwFailure(status, data, 'ADD_FAILED');
  }

  Future<void> deleteMyCertification(String certificationId) async {
    final response = await _dio.delete<dynamic>(
      '/home-services/providers/me/certifications/$certificationId',
    );
    final status = response.statusCode ?? 0;
    if (status == 204 || status == 200) return;
    _throwFailure(status, response.data, 'DELETE_FAILED');
  }

  // ── Specialties ──────────────────────────────────────────────────────────

  Future<List<HomeProviderSpecialtyDto>> getSpecialties(
    String providerId,
  ) async {
    final response = await _dio.get<dynamic>(
      '/home-services/providers/$providerId/specialties',
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map(
            (e) => HomeProviderSpecialtyDto.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    _throwFailure(status, data, 'FETCH_FAILED');
  }

  Future<HomeProviderSpecialtyDto> addMySpecialty(String specialty) async {
    final response = await _dio.post<dynamic>(
      '/home-services/providers/me/specialties',
      data: {'specialty': specialty},
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if ((status == 200 || status == 201) && data is Map<String, dynamic>) {
      return HomeProviderSpecialtyDto.fromJson(data);
    }
    _throwFailure(status, data, 'ADD_FAILED');
  }

  Future<void> deleteMySpecialty(String specialtyId) async {
    final response = await _dio.delete<dynamic>(
      '/home-services/providers/me/specialties/$specialtyId',
    );
    final status = response.statusCode ?? 0;
    if (status == 204 || status == 200) return;
    _throwFailure(status, response.data, 'DELETE_FAILED');
  }

  Never _throwFailure(int status, dynamic data, String fallbackCode) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeProviderAssetsFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw HomeProviderAssetsFailure(
      fallbackCode,
      'Unexpected response ($status).',
    );
  }
}
