import '../entities/pet.dart';

abstract class PetRepository {
  Future<List<Pet>> getMyPets();
  Future<Pet> getById(String id);
  Future<Pet> create({
    required String name,
    String? species,
    String? breed,
    DateTime? birthDate,
    String? description,
    String? photoUrl,
  });
}

class PetFailure implements Exception {
  PetFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PetFailure($code): $message';
}
