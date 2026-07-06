import 'package:dio/dio.dart';

import '../../domain/entities/coach_message.dart';
import '../../domain/repositories/coach_repository.dart';

class CoachRemoteDataSource {
  CoachRemoteDataSource(this._dio);

  final Dio _dio;

  Future<String> sendMessage(
    String message,
    List<CoachMessage> history,
  ) async {
    final response = await _dio.post<dynamic>(
      '/chat',
      data: {
        'Message': message,
        'History': history
            .map((m) => {'Role': m.role == CoachRole.user ? 'user' : 'assistant', 'Content': m.content})
            .toList(),
      },
    );
    final status = response.statusCode ?? 0;
    final raw = response.data;

    // Normalise keys to lowercase so Pascal and camel case both work
    final data = raw is Map<String, dynamic>
        ? {for (final e in raw.entries) e.key.toLowerCase(): e.value}
        : null;

    if (status == 200 && data != null && data['reply'] is String) {
      return data['reply'] as String;
    }

    if (data != null && data['code'] is String && data['error'] is String) {
      throw CoachFailure(data['code'] as String, data['error'] as String);
    }

    if (status == 400) {
      throw CoachFailure('VALIDATION_FAILED', 'Could not send the message.');
    }
    if (status == 503) {
      throw CoachFailure(
          'SERVICE_UNAVAILABLE', 'The coach is not available right now.');
    }

    throw CoachFailure('CHAT_FAILED', 'Unexpected response ($status).');
  }
}
