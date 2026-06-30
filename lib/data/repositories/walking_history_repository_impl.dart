import 'package:dio/dio.dart';

import '../../domain/repositories/walking_history_repository.dart';
import '../datasources/walking_history_remote_datasource.dart';

class WalkingHistoryRepositoryImpl implements WalkingHistoryRepository {
  WalkingHistoryRepositoryImpl(this._remote);

  final WalkingHistoryRemoteDataSource _remote;

  @override
  Future<int> getMyWalkCount() async {
    try {
      final result = await _remote.getMyHistory();
      final items = result['items'] as List?;
      return items?.length ?? 0;
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
