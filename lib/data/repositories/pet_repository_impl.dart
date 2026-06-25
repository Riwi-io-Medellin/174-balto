import 'package:dio/dio.dart';

import '../../domain/entities/pet.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet_remote_datasource.dart';

class PetRepositoryImpl implements PetRepository {
  PetRepositoryImpl(this._remote);

  final PetRemoteDataSource _remote;

  @override
  Future<List<Pet>> getMyPets() async {
    try {
      final dtos = await _remote.getMyPets();
      return dtos.map((dto) => dto.toEntity()).toList();
    } on PetFailure {
      rethrow;
    } on DioException catch (e) {
      throw PetFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<Pet> getById(String id) async {
    try {
      final dto = await _remote.getById(id);
      return dto.toEntity();
    } on PetFailure {
      rethrow;
    } on DioException catch (e) {
      throw PetFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<Pet> create({
    required String name,
    String? species,
    String? breed,
    DateTime? birthDate,
    String? description,
    String? photoUrl,
  }) async {
    try {
      final request = <String, dynamic>{
        'name': name,
        if (species case final v?) 'species': v,
        if (breed case final v?) 'breed': v,
        if (birthDate case final v?)
          'birthDate': v.toIso8601String().split('T').first,
        if (description case final v?) 'description': v,
        if (photoUrl case final v?) 'photoUrl': v,
      };
      final dto = await _remote.create(request);
      return dto.toEntity();
    } on PetFailure {
      rethrow;
    } on DioException catch (e) {
      throw PetFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
