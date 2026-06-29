import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../config/env.dart';

// Hub: WalkTrackingHub mapped at /hubs/walk-tracking (combined with Env.signalrHubUrl base)
// Group key pattern on the server: "walk-{sessionId}"
const _hubPath = '/walk-tracking';
const _joinMethod = 'JoinWalkGroup';
const _leaveMethod = 'LeaveWalkGroup';
const _receiveMethod = 'WalkLocationUpdated';

class WalkTrackingService {
  HubConnection? _connection;
  final _locationController = StreamController<LatLng>.broadcast();

  Stream<LatLng> get locationStream => _locationController.stream;

  Future<void> start(String sessionId, String accessToken) async {
    _connection = HubConnectionBuilder()
        .withUrl(
          '${Env.signalrHubUrl}$_hubPath',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on(_receiveMethod, (args) {
      if (args == null || args.isEmpty) return;
      final data = args[0] as Map<String, dynamic>;
      _locationController.add(LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      ));
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
    _locationController.close();
    _connection?.stop();
  }
}
