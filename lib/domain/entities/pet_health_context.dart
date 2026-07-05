import 'package:equatable/equatable.dart';

class PetHealthContext extends Equatable {
  const PetHealthContext({
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.sex,
    this.weightKg,
    this.symptoms,
    this.documentType,
  });

  final String name;
  final String species;
  final String? breed;
  final int? age;
  final String? sex;
  final double? weightKg;
  final String? symptoms;
  final String? documentType;

  Map<String, dynamic> toJson() => {
        'petContext': {
          'name': name,
          'species': species,
          'breed': breed,
          'age': age,
          'sex': sex,
          'weightKg': weightKg,
        },
        'documentType': documentType,
        'symptoms': symptoms,
      };

  @override
  List<Object?> get props =>
      [name, species, breed, age, sex, weightKg, symptoms, documentType];
}
