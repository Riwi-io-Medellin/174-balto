import 'package:dio/dio.dart';

import '../../domain/entities/coach_message.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/coach_remote_datasource.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl(this._dataSource);

  final CoachRemoteDataSource _dataSource;

  @override
  Future<String> sendMessage(
    String message,
    List<CoachMessage> history,
  ) async {
    try {
      return await _dataSource.sendMessage(message, history);
    } on CoachFailure {
      rethrow;
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      if (status == 401) {
        throw CoachFailure('UNAUTHORIZED', 'Session expired.');
      }
      if (status == 503) {
        throw CoachFailure(
            'SERVICE_UNAVAILABLE', 'The coach is not available.');
      }
      throw CoachFailure('NETWORK_ERROR', 'Connection error. Please try again.');
    } catch (_) {
      throw CoachFailure('UNKNOWN', 'Unexpected error.');
    }
  }
}
