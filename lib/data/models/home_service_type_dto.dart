import '../../domain/entities/home_service_type.dart';

class HomeServiceTypeDto {
  const HomeServiceTypeDto({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory HomeServiceTypeDto.fromJson(Map<String, dynamic> json) {
    return HomeServiceTypeDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  final String id;
  final String code;
  final String name;
  final String? description;

  HomeServiceType toEntity() =>
      HomeServiceType(id: id, code: code, name: name, description: description);
}
