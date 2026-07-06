import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  const Pet({
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

  Pet copyWith({
    bool? isLost,
    double? lostLatitude,
    double? lostLongitude,
    DateTime? lostAt,
  }) {
    return Pet(
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
      isLost: isLost ?? this.isLost,
      lostLatitude: lostLatitude ?? this.lostLatitude,
      lostLongitude: lostLongitude ?? this.lostLongitude,
      lostAt: lostAt ?? this.lostAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        species,
        breed,
        birthDate,
        description,
        photoUrl,
        weight,
        sex,
        color,
        identificationNumber,
        microchipNumber,
        createdAt,
        isLost,
        lostLatitude,
        lostLongitude,
        lostAt,
      ];
}
