import '../../domain/entities/public_pet_tag_info.dart';

class PublicPetTagDto {
  PublicPetTagDto({
    required this.id,
    required this.name,
    this.species,
    this.breed,
    this.photoUrl,
    this.sex,
    this.color,
    this.weight,
    this.birthDate,
    required this.isLost,
    required this.ownerName,
    required this.ownerPhone,
  });

  final String id;
  final String name;
  final String? species;
  final String? breed;
  final String? photoUrl;
  final String? sex;
  final String? color;
  final double? weight;
  final DateTime? birthDate;
  final bool isLost;
  final String ownerName;
  final String ownerPhone;

  factory PublicPetTagDto.fromJson(Map<String, dynamic> json) {
    return PublicPetTagDto(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String?,
      breed: json['breed'] as String?,
      photoUrl: json['photoUrl'] as String?,
      sex: json['sex'] as String?,
      color: json['color'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      isLost: json['isLost'] as bool,
      ownerName: json['ownerName'] as String,
      ownerPhone: json['ownerPhone'] as String,
    );
  }

  PublicPetTagInfo toEntity() => PublicPetTagInfo(
    id: id,
    name: name,
    species: species,
    breed: breed,
    photoUrl: photoUrl,
    sex: sex,
    color: color,
    weight: weight,
    birthDate: birthDate,
    isLost: isLost,
    ownerName: ownerName,
    ownerPhone: ownerPhone,
  );
}
