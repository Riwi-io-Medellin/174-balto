import '../../domain/entities/home_provider_service_item.dart';

class HomeProviderServiceDto {
  const HomeProviderServiceDto({
    required this.id,
    required this.providerId,
    required this.serviceTypeId,
    required this.serviceTypeCode,
    required this.serviceTypeName,
    this.price,
    this.priceUnit = 'flat',
    this.description,
    this.isActive = true,
  });

  factory HomeProviderServiceDto.fromJson(Map<String, dynamic> json) {
    return HomeProviderServiceDto(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      serviceTypeId: json['serviceTypeId'] as String,
      serviceTypeCode: json['serviceTypeCode'] as String? ?? '',
      serviceTypeName: json['serviceTypeName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      priceUnit: json['priceUnit'] as String? ?? 'flat',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String providerId;
  final String serviceTypeId;
  final String serviceTypeCode;
  final String serviceTypeName;
  final double? price;
  final String priceUnit;
  final String? description;
  final bool isActive;

  HomeProviderServiceItem toEntity() => HomeProviderServiceItem(
    id: id,
    serviceTypeId: serviceTypeId,
    serviceTypeCode: serviceTypeCode,
    serviceTypeName: serviceTypeName,
    price: price,
    priceUnit: priceUnit,
    description: description,
    isActive: isActive,
  );
}
