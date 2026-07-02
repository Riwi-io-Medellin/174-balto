import '../entities/home_provider_service_item.dart';

abstract class HomeProviderServicesRepository {
  Future<List<HomeProviderServiceItem>> getByProviderId(String providerId);

  Future<HomeProviderServiceItem> addMyService({
    required String serviceTypeId,
    double? price,
    required String priceUnit,
    String? description,
  });

  Future<HomeProviderServiceItem> updateMyService({
    required String serviceId,
    double? price,
    required String priceUnit,
    String? description,
    required bool isActive,
  });

  Future<void> deleteMyService(String serviceId);
}

class HomeProviderServicesFailure implements Exception {
  HomeProviderServicesFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'HomeProviderServicesFailure($code): $message';
}
