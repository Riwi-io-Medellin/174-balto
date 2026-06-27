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
  });

  final String name;
  final double rating;
  final int reviews;
  final String description;
  final double distance;
  final String imageUrl;
  final String priceLabel;
  final bool topRated;

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
