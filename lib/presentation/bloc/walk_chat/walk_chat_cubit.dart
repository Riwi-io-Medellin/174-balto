import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/walk_chat_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/walk_session_repository.dart';
import 'walk_chat_state.dart';

class WalkChatCubit extends Cubit<WalkChatState> {
  WalkChatCubit({
    required this.sessionId,
    required WalkSessionRepository sessionRepository,
    required WalkChatService chatService,
    required TokenStorage tokenStorage,
  })  : _sessionRepository = sessionRepository,
        _chatService = chatService,
        _tokenStorage = tokenStorage,
        super(const WalkChatInitial());

  final String sessionId;
  final WalkSessionRepository _sessionRepository;
  final WalkChatService _chatService;
  final TokenStorage _tokenStorage;

  StreamSubscription<ChatMessage>? _messageSub;
  StreamSubscription<String>? _errorSub;

  Future<void> start() async {
    try {
      final token = await _tokenStorage.readAccessToken() ?? '';
      final currentUserId = JwtDecoder.extractUserId(token) ?? '';

      final history = await _sessionRepository.getChatMessages(sessionId);
      emit(WalkChatLoaded(currentUserId: currentUserId, messages: history));

      await _chatService.start(sessionId, token);
      _messageSub = _chatService.messageStream.listen(_onMessage);
      _errorSub = _chatService.errorStream.listen((msg) {
        final s = state;
        if (s is WalkChatLoaded) emit(s.copyWith(sendError: msg));
      });
    } catch (e) {
      emit(WalkChatError(e.toString()));
    }
  }

  void _onMessage(ChatMessage message) {
    final s = state;
    if (s is! WalkChatLoaded) return;
    if (s.messages.any((m) => m.id == message.id)) return;
    emit(s.copyWith(messages: [...s.messages, message]));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _sessionRepository.sendChatMessage(sessionId, text.trim());
    } catch (e) {
      final s = state;
      if (s is WalkChatLoaded) emit(s.copyWith(sendError: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    _messageSub?.cancel();
    _errorSub?.cancel();
    await _chatService.stop(sessionId);
    _chatService.dispose();
    return super.close();
  }
}
