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
        createdAt,
      ];
}
