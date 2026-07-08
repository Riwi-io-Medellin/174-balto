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
    double? weight,
    String? sex,
  }) async {
    try {
      final request = <String, dynamic>{
        'name': name,
        'species': ?species,
        'breed': ?breed,
        if (birthDate case final v?)
          'birthDate': v.toIso8601String().split('T').first,
        'description': ?description,
        'photoUrl': ?photoUrl,
        'weight': ?weight,
        'sex': ?sex,
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

  @override
  Future<Pet> update({
    required String id,
    required String name,
    String? species,
    String? breed,
    DateTime? birthDate,
    String? description,
    String? photoUrl,
    double? weight,
    String? sex,
  }) async {
    try {
      final request = <String, dynamic>{
        'name': name,
        'species': ?species,
        'breed': ?breed,
        if (birthDate case final v?)
          'birthDate': v.toIso8601String().split('T').first,
        'description': ?description,
        'photoUrl': ?photoUrl,
        'weight': ?weight,
        'sex': ?sex,
      };
      final dto = await _remote.update(id, request);
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
  Future<void> delete(String id) async {
    try {
      await _remote.delete(id);
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
  Future<Pet> reportLost({
    required String id,
    required double lostLatitude,
    required double lostLongitude,
  }) async {
    try {
      final dto = await _remote.reportLost(
        id,
        lostLatitude: lostLatitude,
        lostLongitude: lostLongitude,
      );
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
  Future<Pet> markFound(String id) async {
    try {
      final dto = await _remote.markFound(id);
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
