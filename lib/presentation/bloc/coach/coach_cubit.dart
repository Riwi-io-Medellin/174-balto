import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/coach_message.dart';
import '../../../domain/repositories/coach_repository.dart';
import 'coach_state.dart';

class CoachCubit extends Cubit<CoachState> {
  CoachCubit(this._repository, this._storage) : super(const CoachInitial());

  final CoachRepository _repository;
  final FlutterSecureStorage _storage;

  static const _storageKey = 'coach_chat_history';

  Future<void> init() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        final messages = list
            .map((e) => CoachMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(CoachLoaded(messages: messages));
        return;
      } catch (_) {}
    }
    emit(const CoachLoaded());
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = state is CoachLoaded
        ? (state as CoachLoaded).messages
        : <CoachMessage>[];
    final userMsg = CoachMessage(role: CoachRole.user, content: trimmed);
    final withUser = [...current, userMsg];

    emit(CoachLoaded(messages: withUser, isTyping: true));

    try {
      final reply = await _repository.sendMessage(trimmed, current);
      final assistantMsg = CoachMessage(
        role: CoachRole.assistant,
        content: reply,
      );
      final withReply = [...withUser, assistantMsg];
      emit(CoachLoaded(messages: withReply));
      await _save(withReply);
    } on CoachFailure catch (e) {
      emit(CoachLoaded(messages: withUser, sendError: e.message));
    } catch (_) {
      emit(CoachLoaded(messages: withUser, sendError: 'Unexpected error.'));
    }
  }

  Future<void> clearHistory() async {
    await _storage.delete(key: _storageKey);
    emit(const CoachLoaded());
  }

  Future<void> _save(List<CoachMessage> messages) async {
    final json = jsonEncode(messages.map((m) => m.toJson()).toList());
    await _storage.write(key: _storageKey, value: json);
  }
}
