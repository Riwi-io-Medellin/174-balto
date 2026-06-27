import 'package:dio/dio.dart';

import '../../domain/entities/feedback_summary.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_remote_datasource.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  FeedbackRepositoryImpl(this._remote);

  final FeedbackRemoteDataSource _remote;

  @override
  Future<FeedbackSummary?> getByWalker(String walkerId) async {
    try {
      final dto = await _remote.getByWalker(walkerId);
      return dto?.toEntity();
    } on FeedbackFailure {
      rethrow;
    } on DioException catch (e) {
      throw FeedbackFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
