import 'package:equatable/equatable.dart';

class PublicPetTagInfo extends Equatable {
  const PublicPetTagInfo({
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

  @override
  List<Object?> get props => [
    id,
    name,
    species,
    breed,
    photoUrl,
    sex,
    color,
    weight,
    birthDate,
    isLost,
    ownerName,
    ownerPhone,
  ];
}
