import '../../domain/entities/pet.dart';

class PetDto {
  PetDto({
    required this.id,
    required this.userId,
    required this.name,
    this.species,
    this.breed,
    this.birthDate,
    this.description,
    this.photoUrl,
    this.weight,
    this.sex,
    this.color,
    this.identificationNumber,
    this.microchipNumber,
    required this.createdAt,
    this.isLost = false,
    this.lostLatitude,
    this.lostLongitude,
    this.lostAt,
    this.latestHealthUrgency,
    this.tagScanLatitude,
    this.tagScanLongitude,
    this.tagScanAt,
  });

  final String id;
  final String userId;
  final String name;
  final String? species;
  final String? breed;
  final DateTime? birthDate;
  final String? description;
  final String? photoUrl;
  final double? weight;
  final String? sex;
  final String? color;
  final String? identificationNumber;
  final String? microchipNumber;
  final DateTime createdAt;
  final bool isLost;
  final double? lostLatitude;
  final double? lostLongitude;
  final DateTime? lostAt;
  final String? latestHealthUrgency;
  final double? tagScanLatitude;
  final double? tagScanLongitude;
  final DateTime? tagScanAt;

  factory PetDto.fromJson(Map<String, dynamic> json) {
    return PetDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      species: json['species'] as String?,
      breed: json['breed'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse((json['birthDate'] as String).split('T').first)
          : null,
      description: json['description'] as String?,
      photoUrl: json['photoUrl'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      sex: json['sex'] as String?,
      color: json['color'] as String?,
      identificationNumber: json['identificationNumber'] as String?,
      microchipNumber: json['microchipNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      isLost: json['isLost'] as bool? ?? false,
      lostLatitude: (json['lostLatitude'] as num?)?.toDouble(),
      lostLongitude: (json['lostLongitude'] as num?)?.toDouble(),
      lostAt: json['lostAt'] != null
          ? DateTime.parse(json['lostAt'] as String).toLocal()
          : null,
      latestHealthUrgency: json['latestHealthUrgency'] as String?,
      tagScanLatitude: (json['tagScanLatitude'] as num?)?.toDouble(),
      tagScanLongitude: (json['tagScanLongitude'] as num?)?.toDouble(),
      tagScanAt: json['tagScanAt'] != null
          ? DateTime.parse(json['tagScanAt'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (species != null) 'species': species,
    if (breed != null) 'breed': breed,
    if (birthDate != null)
      'birthDate': birthDate!.toIso8601String().split('T').first,
    if (description != null) 'description': description,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (weight != null) 'weight': weight,
  };

  Pet toEntity() => Pet(
    id: id,
    userId: userId,
    name: name,
    species: species,
    breed: breed,
    birthDate: birthDate,
    description: description,
    photoUrl: photoUrl,
    weight: weight,
    sex: sex,
    color: color,
    identificationNumber: identificationNumber,
    microchipNumber: microchipNumber,
    createdAt: createdAt,
    isLost: isLost,
    lostLatitude: lostLatitude,
    lostLongitude: lostLongitude,
    lostAt: lostAt,
    latestHealthUrgency: latestHealthUrgency,
    tagScanLatitude: tagScanLatitude,
    tagScanLongitude: tagScanLongitude,
    tagScanAt: tagScanAt,
  );
}
