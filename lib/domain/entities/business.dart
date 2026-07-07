import 'package:equatable/equatable.dart';

class Business extends Equatable {
  const Business({
    this.id = '',
    required this.ownerUserId,
    required this.name,
    required this.nit,
    required this.email,
    required this.phone,
    this.type,
    this.location,
    this.address,
    this.verificationStatus = 'pending',
    required this.createdAt,
    this.instagramUrl,
    this.facebookUrl,
    this.description,
    this.photoUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.latitude,
    this.longitude,
    this.isOpen = false,
    this.distanceKm,
    this.sellsServices = false,
    this.sellsProducts = false,
    this.services = const [],
    this.openingHours = const [],
    this.gallery = const [],
  });

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
  final double rating;
  final int reviewCount;
  final double? latitude;
  final double? longitude;
  final bool isOpen;

  /// Computed client-side from the user's current GPS position (see BusinessCubit).
  /// Null when the business or the user has no known coordinates yet.
  final double? distanceKm;

  /// Market feature: independent toggles so a business can sell services,
  /// products, both, or neither (hides the Market tab on the profile).
  final bool sellsServices;
  final bool sellsProducts;

  final List<BusinessServiceItem> services;
  final List<BusinessHour> openingHours;

  /// Gallery photos (backed by business_documents, documentType='gallery').
  final List<BusinessDocumentItem> gallery;

  bool get isVeterinary => type == 'veterinary';
  bool get isStore => type == 'petshop';
  bool get isVerified => verificationStatus == 'approved';
  bool get hasMarket => sellsServices || sellsProducts;

  List<BusinessServiceItem> get serviceItems =>
      services.where((s) => s.itemKind == 'service').toList();
  List<BusinessServiceItem> get productItems =>
      services.where((s) => s.itemKind == 'product').toList();

  Business copyWith({double? distanceKm}) => Business(
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
        rating: rating,
        reviewCount: reviewCount,
        latitude: latitude,
        longitude: longitude,
        isOpen: isOpen,
        distanceKm: distanceKm ?? this.distanceKm,
        sellsServices: sellsServices,
        sellsProducts: sellsProducts,
        services: services,
        openingHours: openingHours,
        gallery: gallery,
      );

  @override
  List<Object?> get props => [id];
}

class BusinessServiceItem extends Equatable {
  const BusinessServiceItem({
    this.id = '',
    required this.businessId,
    required this.serviceType,
    required this.price,
    this.description,
    this.photoUrl,
    this.itemKind = 'service',
  });

  final String id;
  final String businessId;
  final String serviceType;
  final double price;
  final String? description;
  final String? photoUrl;

  /// 'service' or 'product' — same table backs both sides of the Market feature.
  final String itemKind;

  bool get isProduct => itemKind == 'product';

  @override
  List<Object?> get props => [id, serviceType, price, itemKind];
}

/// A single business gallery photo (backed by business_documents,
/// documentType = 'gallery'). Kept separate from the main [Business.photoUrl].
class BusinessDocumentItem extends Equatable {
  const BusinessDocumentItem({
    required this.id,
    required this.businessId,
    required this.documentType,
    required this.fileUrl,
  });

  final String id;
  final String businessId;
  final String documentType;
  final String fileUrl;

  @override
  List<Object?> get props => [id];
}

/// Weekly recurring opening hour for a single day (0 = Sunday ... 6 = Saturday).
class BusinessHour extends Equatable {
  const BusinessHour({
    this.id = '',
    required this.businessId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  final String id;
  final String businessId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;

  static const List<String> dayLabels = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String get dayLabel =>
      dayOfWeek >= 0 && dayOfWeek < dayLabels.length ? dayLabels[dayOfWeek] : '';

  @override
  List<Object?> get props => [id, dayOfWeek, startTime, endTime, isActive];
}
