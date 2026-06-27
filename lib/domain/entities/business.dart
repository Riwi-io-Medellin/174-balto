import 'package:equatable/equatable.dart';

class Business extends Equatable {
  const Business({
    required this.id,
    required this.name,
    required this.isVeterinary,
    required this.isStore,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.isOpen,
    required this.description,
    required this.coverImage,
    required this.logoImage,
    this.features = const [],
    this.address,
    this.phone,
    this.openingHours = const {},
    this.services = const [],
    this.products = const [],
    this.facilities = const [],
  });

  final String id;
  final String name;
  final bool isVeterinary;
  final bool isStore;
  final double rating;
  final int reviewCount;
  final double distance;
  final bool isOpen;
  final String description;
  final String coverImage;
  final String logoImage;
  final List<String> features;
  final String? address;
  final String? phone;
  final Map<String, String> openingHours;
  final List<ServiceItem> services;
  final List<ProductItem> products;
  final List<String> facilities;

  @override
  List<Object?> get props => [id];
}

class ServiceItem extends Equatable {
  const ServiceItem({
    required this.name,
    required this.description,
    this.price,
    this.imageUrl,
    this.tags = const [],
  });

  final String name;
  final String description;
  final double? price;
  final String? imageUrl;
  final List<String> tags;

  @override
  List<Object?> get props => [name, price];
}

class ProductItem extends Equatable {
  const ProductItem({
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
  });

  final String name;
  final double price;
  final String? description;
  final String? imageUrl;

  @override
  List<Object?> get props => [name, price];
}
