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
        throw CoachFailure('UNAUTHORIZED', 'Sesión expirada.');
      }
      if (status == 503) {
        throw CoachFailure(
            'SERVICE_UNAVAILABLE', 'El coach no está disponible.');
      }
      throw CoachFailure('NETWORK_ERROR', 'Error de conexión. Intenta de nuevo.');
    } catch (_) {
      throw CoachFailure('UNKNOWN', 'Error inesperado.');
    }
  }
}
