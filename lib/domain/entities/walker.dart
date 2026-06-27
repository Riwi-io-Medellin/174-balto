import 'package:equatable/equatable.dart';

class Walker extends Equatable {
  const Walker({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.distance,
    required this.imageUrl,
    required this.priceLabel,
    this.topRated = false,
    this.isVerified = false,
    this.yearsOfExperience = 0,
    this.biography,
    this.specialties = const [],
    this.galleryImages = const [],
    this.pricePerWalk,
    this.serviceArea,
    this.maxDogs,
    this.completedWalks,
    this.avatarUrl,
  });

  final String name;
  final double rating;
  final int reviews;
  final String description;
  final double distance;
  final String imageUrl;
  final String priceLabel;
  final bool topRated;
  final bool isVerified;
  final int yearsOfExperience;
  final String? biography;
  final List<String> specialties;
  final List<String> galleryImages;
  final double? pricePerWalk;
  final String? serviceArea;
  final int? maxDogs;
  final int? completedWalks;
  final String? avatarUrl;

  @override
  List<Object?> get props => [
        name,
        rating,
        reviews,
        description,
        distance,
        imageUrl,
        priceLabel,
        topRated,
      ];
}
