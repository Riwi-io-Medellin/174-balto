import 'package:dio/dio.dart';

import '../../domain/entities/business.dart';
import '../../domain/entities/business_hour_exception.dart';
import '../../domain/repositories/business_repository.dart';
import '../../domain/repositories/upload_repository.dart';
import '../datasources/business_remote_datasource.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  BusinessRepositoryImpl(this._remote, this._uploadRepository);

  final BusinessRemoteDataSource _remote;
  final UploadRepository _uploadRepository;

  @override
  Future<List<Business>> getBusinesses({String? type, String? location}) async {
    try {
      final result = await _remote.getBusinesses(
        type: type,
        location: location,
      );
      return result.map((dto) => dto.toEntity()).toList();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<Business> getBusinessDetail(String businessId) async {
    try {
      final businessDtoFuture = _remote.getBusinessDetail(businessId);
      final hoursFuture = _remote.getBusinessHours(businessId);
      final servicesFuture = _remote.getBusinessServices(businessId);
      final documentsFuture = _remote.getBusinessDocuments(businessId);

      final businessDto = await businessDtoFuture;
      final hours = (await hoursFuture).map((h) => h.toEntity()).toList();
      final services = (await servicesFuture)
          .map((s) => s.toEntity())
          .toList();
      final gallery = (await documentsFuture)
          .where((d) => d.documentType == 'gallery')
          .map((d) => d.toEntity())
          .toList();

      return businessDto.toEntity(
        services: services,
        openingHours: hours,
        gallery: gallery,
      );
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
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
  }) async {
    try {
      final dto = await _remote.createBusiness(
        name: name,
        nit: nit,
        email: email,
        phone: phone,
        type: type,
        location: location,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
      return dto.toEntity();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<Business?> getMyBusiness() async {
    try {
      final dto = await _remote.getMyBusiness();
      return dto?.toEntity();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<Business> updateMyBusiness({
    String? instagramUrl,
    String? facebookUrl,
    String? description,
    String? photoUrl,
    bool? sellsServices,
    bool? sellsProducts,
  }) async {
    try {
      final dto = await _remote.updateMyBusiness(
        instagramUrl: instagramUrl,
        facebookUrl: facebookUrl,
        description: description,
        photoUrl: photoUrl,
        sellsServices: sellsServices,
        sellsProducts: sellsProducts,
      );
      return dto.toEntity();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<BusinessHour>> getBusinessHours(String businessId) async {
    try {
      final result = await _remote.getBusinessHours(businessId);
      return result.map((dto) => dto.toEntity()).toList();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<BusinessServiceItem>> getBusinessServices(
    String businessId,
  ) async {
    try {
      final result = await _remote.getBusinessServices(businessId);
      return result.map((dto) => dto.toEntity()).toList();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<BusinessHourException>> getBusinessHourExceptions(
    String businessId,
  ) async {
    try {
      final result = await _remote.getBusinessHourExceptions(businessId);
      return result.map((dto) => dto.toEntity()).toList();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<BusinessHour>> updateMyHours(List<BusinessHour> hours) async {
    try {
      final payload = hours
          .map(
            (h) => {
              'dayOfWeek': h.dayOfWeek,
              'startTime': h.startTime,
              'endTime': h.endTime,
              'isActive': h.isActive,
            },
          )
          .toList();
      final result = await _remote.updateMyHours(payload);
      return result.map((dto) => dto.toEntity()).toList();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> addBusinessDocument({
    required String businessId,
    required String documentType,
    required String fileUrl,
  }) async {
    try {
      await _remote.addBusinessDocument(
        businessId: businessId,
        documentType: documentType,
        fileUrl: fileUrl,
      );
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
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
  }) async {
    try {
      final created = await _remote.createBusiness(
        name: name,
        nit: nit,
        email: email,
        phone: phone,
        type: type,
        location: location,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      final fileUrl = await _uploadRepository.uploadImage(documentImagePath);

      await _remote.addBusinessDocument(
        businessId: created.id,
        documentType: 'nit',
        fileUrl: fileUrl,
      );

      return created.toEntity();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<List<BusinessDocumentItem>> getBusinessDocuments(
    String businessId,
  ) async {
    try {
      final result = await _remote.getBusinessDocuments(businessId);
      return result.map((dto) => dto.toEntity()).toList();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> deleteBusinessDocument({
    required String businessId,
    required String documentId,
  }) async {
    try {
      await _remote.deleteBusinessDocument(
        businessId: businessId,
        documentId: documentId,
      );
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  /// Picks an image, uploads it, then registers it as a gallery photo.
  @override
  Future<void> addGalleryPhoto({
    required String businessId,
    required String imagePath,
  }) async {
    final url = await _uploadRepository.uploadImage(imagePath);
    await addBusinessDocument(
      businessId: businessId,
      documentType: 'gallery',
      fileUrl: url,
    );
  }

  @override
  Future<BusinessServiceItem> createBusinessService({
    required String businessId,
    required String serviceType,
    required double price,
    String? description,
    String? photoUrl,
    String itemKind = 'service',
  }) async {
    try {
      final dto = await _remote.createBusinessService(
        businessId: businessId,
        serviceType: serviceType,
        price: price,
        description: description,
        photoUrl: photoUrl,
        itemKind: itemKind,
      );
      return dto.toEntity();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<BusinessServiceItem> updateBusinessService({
    required String businessId,
    required String serviceId,
    required String serviceType,
    required double price,
    String? description,
    String? photoUrl,
    String itemKind = 'service',
  }) async {
    try {
      final dto = await _remote.updateBusinessService(
        businessId: businessId,
        serviceId: serviceId,
        serviceType: serviceType,
        price: price,
        description: description,
        photoUrl: photoUrl,
        itemKind: itemKind,
      );
      return dto.toEntity();
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> deleteBusinessService({
    required String businessId,
    required String serviceId,
  }) async {
    try {
      await _remote.deleteBusinessService(
        businessId: businessId,
        serviceId: serviceId,
      );
    } on BusinessFailure {
      rethrow;
    } on DioException catch (e) {
      throw BusinessFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
