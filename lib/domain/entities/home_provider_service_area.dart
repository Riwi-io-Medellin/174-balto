import 'package:equatable/equatable.dart';

class HomeProviderServiceArea extends Equatable {
  const HomeProviderServiceArea({
    this.id = '',
    this.label,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  final String id;
  final String? label;
  final double latitude;
  final double longitude;
  final double radiusKm;

  @override
  List<Object?> get props => [id, label, latitude, longitude, radiusKm];
}
