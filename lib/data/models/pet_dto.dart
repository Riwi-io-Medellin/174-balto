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
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String? species;
  final String? breed;
  final DateTime? birthDate;
  final String? description;
  final String? photoUrl;
  final DateTime createdAt;

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
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
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
        createdAt: createdAt,
      );
}
