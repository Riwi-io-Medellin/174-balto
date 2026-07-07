import '../../domain/entities/business.dart';
import '../../domain/entities/business_hour_exception.dart';

/// Maps backend BusinessResponse into a [Business] entity.
/// Services and opening hours are attached separately by the repository
/// (they come from different endpoints), so they default to empty here.
class BusinessDto {
  BusinessDto({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.nit,
    required this.email,
    required this.phone,
    this.type,
    this.location,
    this.address,
    required this.verificationStatus,
    required this.createdAt,
    this.instagramUrl,
    this.facebookUrl,
    this.description,
    this.photoUrl,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.latitude,
    this.longitude,
    this.isOpenNow = false,
    this.sellsServices = false,
    this.sellsProducts = false,
  });

  factory BusinessDto.fromJson(Map<String, dynamic> json) {
    return BusinessDto(
      id: json['id'] as String,
      ownerUserId: json['ownerUserId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nit: json['nit'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: (json['phone'] ?? '').toString(),
      type: json['type'] as String?,
      location: json['location'] as String?,
      address: json['address'] as String?,
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      instagramUrl: json['instagramUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      description: json['description'] as String?,
      photoUrl: json['photoUrl'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      sellsServices: json['sellsServices'] as bool? ?? false,
      sellsProducts: json['sellsProducts'] as bool? ?? false,
    );
  }

  final String id;
  final String ownerUserId;
  final String name;
  final String nit;
  final String email;
  final String phone;
  final String? type;
  final String? location;
  final String? address;
  final String verificationStatus;
  final DateTime createdAt;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? description;
  final String? photoUrl;
  final double averageRating;
  final int totalReviews;
  final double? latitude;
  final double? longitude;
  final bool isOpenNow;
  final bool sellsServices;
  final bool sellsProducts;

  Business toEntity({
    List<BusinessServiceItem> services = const [],
    List<BusinessHour> openingHours = const [],
    List<BusinessDocumentItem> gallery = const [],
  }) => Business(
    id: id,
    ownerUserId: ownerUserId,
    name: name,
    nit: nit,
    email: email,
    phone: phone,
    type: type,
    location: location,
    address: address,
    verificationStatus: verificationStatus,
    createdAt: createdAt,
    instagramUrl: instagramUrl,
    facebookUrl: facebookUrl,
    description: description,
    photoUrl: photoUrl,
    rating: averageRating,
    reviewCount: totalReviews,
    latitude: latitude,
    longitude: longitude,
    isOpen: isOpenNow,
    sellsServices: sellsServices,
    sellsProducts: sellsProducts,
    services: services,
    openingHours: openingHours,
    gallery: gallery,
  );
}

class BusinessServiceItemDto {
  BusinessServiceItemDto({
    required this.id,
    required this.businessId,
    required this.serviceType,
    required this.price,
    this.description,
    this.photoUrl,
    this.itemKind = 'service',
  });

  factory BusinessServiceItemDto.fromJson(Map<String, dynamic> json) {
    return BusinessServiceItemDto(
      id: json['id'] as String,
      businessId: json['businessId'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      photoUrl: json['photoUrl'] as String?,
      itemKind: json['itemKind'] as String? ?? 'service',
    );
  }

  final String id;
  final String businessId;
  final String serviceType;
  final double price;
  final String? description;
  final String? photoUrl;
  final String itemKind;

  BusinessServiceItem toEntity() => BusinessServiceItem(
    id: id,
    businessId: businessId,
    serviceType: serviceType,
    price: price,
    description: description,
    photoUrl: photoUrl,
    itemKind: itemKind,
  );
}

class BusinessDocumentDto {
  BusinessDocumentDto({
    required this.id,
    required this.businessId,
    required this.documentType,
    required this.fileUrl,
  });

  factory BusinessDocumentDto.fromJson(Map<String, dynamic> json) {
    return BusinessDocumentDto(
      id: json['id'] as String,
      businessId: json['businessId'] as String? ?? '',
      documentType: json['documentType'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
    );
  }

  static List<BusinessDocumentDto> fromJsonList(List<dynamic> list) => list
      .map((e) => BusinessDocumentDto.fromJson(e as Map<String, dynamic>))
      .toList();

  final String id;
  final String businessId;
  final String documentType;
  final String fileUrl;

  BusinessDocumentItem toEntity() => BusinessDocumentItem(
    id: id,
    businessId: businessId,
    documentType: documentType,
    fileUrl: fileUrl,
  );
}

class BusinessHourDto {
  BusinessHourDto({
    required this.id,
    required this.businessId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory BusinessHourDto.fromJson(Map<String, dynamic> json) {
    return BusinessHourDto(
      id: json['id'] as String,
      businessId: json['businessId'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static List<BusinessHourDto> fromJsonList(List<dynamic> list) => list
      .map((e) => BusinessHourDto.fromJson(e as Map<String, dynamic>))
      .toList();

  final String id;
  final String businessId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;

  BusinessHour toEntity() => BusinessHour(
    id: id,
    businessId: businessId,
    dayOfWeek: dayOfWeek,
    startTime: startTime,
    endTime: endTime,
    isActive: isActive,
  );
}

class BusinessHourExceptionDto {
  BusinessHourExceptionDto({
    required this.id,
    required this.businessId,
    required this.date,
    required this.isUnavailable,
    this.startTime,
    this.endTime,
  });

  factory BusinessHourExceptionDto.fromJson(Map<String, dynamic> json) {
    return BusinessHourExceptionDto(
      id: json['id'] as String,
      businessId: json['businessId'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      isUnavailable: json['isUnavailable'] as bool? ?? false,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }

  static List<BusinessHourExceptionDto> fromJsonList(List<dynamic> list) => list
      .map((e) => BusinessHourExceptionDto.fromJson(e as Map<String, dynamic>))
      .toList();

  final String id;
  final String businessId;
  final DateTime date;
  final bool isUnavailable;
  final String? startTime;
  final String? endTime;

  BusinessHourException toEntity() => BusinessHourException(
    id: id,
    businessId: businessId,
    date: date,
    isUnavailable: isUnavailable,
    startTime: startTime,
    endTime: endTime,
  );
}
