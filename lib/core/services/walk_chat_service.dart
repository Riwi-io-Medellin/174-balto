import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../../domain/entities/chat_message.dart';
import '../config/env.dart';

// Hub: WalkTrackingHub mapped at /hubs/walk-tracking (combined with Env.signalrHubUrl base)
// Group key pattern on the server: "walk-{sessionId}"
const _hubPath = '/walk-tracking';
const _joinMethod = 'JoinWalkGroup';
const _leaveMethod = 'LeaveWalkGroup';
const _receiveMethod = 'ChatMessageReceived';

class WalkChatService {
  HubConnection? _connection;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Future<void> start(String sessionId, String accessToken) async {
    _connection = HubConnectionBuilder()
        .withUrl(
          '${Env.signalrHubUrl}$_hubPath',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
            transport: HttpTransportType.LongPolling,
            requestTimeout: 15000,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('Error', (args) {
      final msg = args?.firstOrNull?.toString() ?? 'Hub error';
      // ignore: avoid_print
      print('[WalkChat] Hub error: $msg');
      _errorController.add(msg);
    });

    _connection!.on(_receiveMethod, (args) {
      try {
        if (args == null || args.isEmpty) return;
        final raw = Map<String, dynamic>.from(args[0] as Map);
        final id = (raw['id'] ?? raw['Id']) as String?;
        final walkSessionId =
            (raw['walkSessionId'] ?? raw['WalkSessionId']) as String?;
        final senderUserId =
            (raw['senderUserId'] ?? raw['SenderUserId']) as String?;
        final text = (raw['text'] ?? raw['Text']) as String?;
        final createdAtRaw = (raw['createdAt'] ?? raw['CreatedAt']) as String?;
        if (id == null ||
            walkSessionId == null ||
            senderUserId == null ||
            text == null) {
          return;
        }
        _messageController.add(
          ChatMessage(
            id: id,
            walkSessionId: walkSessionId,
            senderUserId: senderUserId,
            text: text,
            createdAt: createdAtRaw != null
                ? DateTime.parse(createdAtRaw)
                : DateTime.now(),
          ),
        );
      } catch (e) {
        // ignore: avoid_print
        print('[WalkChat] ChatMessageReceived error: $e');
      }
    });

    await _connection!.start();
    await _connection!.invoke(_joinMethod, args: [sessionId]);
  }

  Future<void> stop(String sessionId) async {
    try {
      await _connection?.invoke(_leaveMethod, args: [sessionId]);
    } catch (_) {}
    await _connection?.stop();
    _connection = null;
  }

  void dispose() {
    _messageController.close();
    _errorController.close();
    _connection?.stop();
  }
}
