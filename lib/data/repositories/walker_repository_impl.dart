import 'package:dio/dio.dart';

import '../../domain/entities/walker.dart';
import '../../domain/repositories/walker_repository.dart';
import '../datasources/walker_remote_datasource.dart';

class WalkerRepositoryImpl implements WalkerRepository {
  WalkerRepositoryImpl(this._remote);

  final WalkerRemoteDataSource _remote;

  @override
  Future<List<Walker>> getAll() async {
    try {
      final dtos = await _remote.getAll();
      return dtos.map((dto) => dto.toEntity()).toList();
    } on WalkerFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkerFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<Walker?> findByUserId(String userId) async {
    final walkers = await getAll();
    for (final w in walkers) {
      if (w.userId == userId) return w;
    }
    return null;
  }
}
