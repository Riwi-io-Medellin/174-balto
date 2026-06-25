import 'package:dio/dio.dart';

import '../../domain/repositories/walking_history_repository.dart';
import '../datasources/walking_history_remote_datasource.dart';

class WalkingHistoryRepositoryImpl implements WalkingHistoryRepository {
  WalkingHistoryRepositoryImpl(this._remote);

  final WalkingHistoryRemoteDataSource _remote;

  @override
  Future<int> getMyWalkCount() async {
    try {
      final history = await _remote.getMyHistory();
      return history.length;
    } on WalkingHistoryFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkingHistoryFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
