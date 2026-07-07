import '../../domain/entities/home_provider_service_area.dart';

class HomeProviderServiceAreaDto {
  const HomeProviderServiceAreaDto({
    required this.id,
    this.label,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  factory HomeProviderServiceAreaDto.fromJson(Map<String, dynamic> json) {
    return HomeProviderServiceAreaDto(
      id: json['id'] as String,
      label: json['label'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusKm: (json['radiusKm'] as num).toDouble(),
    );
  }

  static List<HomeProviderServiceAreaDto> fromJsonList(List<dynamic> json) =>
      json
          .map(
            (e) =>
                HomeProviderServiceAreaDto.fromJson(e as Map<String, dynamic>),
          )
          .toList();

  final String id;
  final String? label;
  final double latitude;
  final double longitude;
  final double radiusKm;

  Map<String, dynamic> toJson() => {
    'label': label,
    'latitude': latitude,
    'longitude': longitude,
    'radiusKm': radiusKm,
  };

  HomeProviderServiceArea toEntity() => HomeProviderServiceArea(
    id: id,
    label: label,
    latitude: latitude,
    longitude: longitude,
    radiusKm: radiusKm,
  );
}
