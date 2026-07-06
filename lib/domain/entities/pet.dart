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
    required this.createdAt,
    this.latestHealthUrgency,
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
  final DateTime createdAt;
  final String? latestHealthUrgency;

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
        createdAt,
        latestHealthUrgency,
      ];
}
