import 'package:dio/dio.dart';

import '../../domain/entities/me.dart';
import '../../domain/repositories/me_repository.dart';
import '../datasources/me_remote_datasource.dart';

class MeRepositoryImpl implements MeRepository {
  MeRepositoryImpl(this._remote);

  final MeRemoteDataSource _remote;

  @override
  Future<Me> get() async {
    try {
      final dto = await _remote.get();
      return dto.toEntity();
    } on MeFailure {
      rethrow;
    } on DioException catch (e) {
      throw MeFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
