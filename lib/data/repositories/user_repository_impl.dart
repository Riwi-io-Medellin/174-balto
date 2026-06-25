import 'package:dio/dio.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Future<User> getById(String id) async {
    try {
      final dto = await _remote.getById(id);
      return dto.toEntity();
    } on UserFailure {
      rethrow;
    } on DioException catch (e) {
      throw UserFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<User> update({
    required String id,
    required String firstName,
    required String lastName,
    required String idNumber,
    required String idType,
    required String phone,
    String? phoneExtra,
    String? location,
    String? address,
    String? photoUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'idNumber': idNumber,
        'idType': idType,
        'phone': phone,
        if (phoneExtra case final v?) 'phoneExtra': v,
        if (location case final v?) 'location': v,
        if (address case final v?) 'address': v,
        if (photoUrl case final v?) 'photoUrl': v,
      };
      final dto = await _remote.update(id, data);
      return dto.toEntity();
    } on UserFailure {
      rethrow;
    } on DioException catch (e) {
      throw UserFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
