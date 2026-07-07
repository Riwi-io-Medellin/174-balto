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
const _completedMethod = 'WalkCompleted';

class WalkTrackingService {
  HubConnection? _connection;
  final _locationController = StreamController<LatLng>.broadcast();
  final _completedController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Stream<LatLng> get locationStream => _locationController.stream;
  Stream<Map<String, dynamic>?> get walkCompletedStream =>
      _completedController.stream;

  // Error stream so the cubit can react to hub-level errors (e.g. auth failure).
  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  Future<void> start(String sessionId, String accessToken) async {
    _connection = HubConnectionBuilder()
        .withUrl(
          '${Env.signalrHubUrl}$_hubPath',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
            // Long Polling works through standard HTTP reverse proxies without
            // needing WebSocket Upgrade headers configured in nginx.
            transport: HttpTransportType.LongPolling,
            // Default requestTimeout is 2 s which is too short for a remote
            // server — the negotiate POST alone can exceed it.
            requestTimeout: 15000,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('Error', (args) {
      final msg = args?.firstOrNull?.toString() ?? 'Hub error';
      // ignore: avoid_print
      print('[WalkTracking] Hub error: $msg');
      _errorController.add(msg);
    });

    _connection!.on(_receiveMethod, (args) {
      try {
        // ignore: avoid_print
        print('[WalkTracking] WalkLocationUpdated raw: $args');
        if (args == null || args.isEmpty) return;
        final raw = args[0];
        // SignalR may deliver as Map<Object?,Object?> — cast safely.
        final data = Map<String, dynamic>.from(raw as Map);
        final lat = (data['Latitude'] ?? data['latitude']) as num?;
        final lng = (data['Longitude'] ?? data['longitude']) as num?;
        // ignore: avoid_print
        print('[WalkTracking] lat=$lat lng=$lng');
        if (lat == null || lng == null) return;
        _locationController.add(LatLng(lat.toDouble(), lng.toDouble()));
      } catch (e) {
        // ignore: avoid_print
        print('[WalkTracking] WalkLocationUpdated error: $e');
      }
    });

    _connection!.on(_completedMethod, (args) {
      try {
        // ignore: avoid_print
        print('[WalkTracking] WalkCompleted raw: $args');
        Map<String, dynamic>? payload;
        if (args != null && args.isNotEmpty) {
          final raw = Map<String, dynamic>.from(args[0] as Map);
          payload = {
            'distanceMeters': raw['distanceMeters'] ?? raw['DistanceMeters'],
            'durationSeconds': raw['durationSeconds'] ?? raw['DurationSeconds'],
          };
        }
        _completedController.add(payload);
      } catch (e) {
        // ignore: avoid_print
        print('[WalkTracking] WalkCompleted error: $e');
        _completedController.add(null);
      }
    });

    await _connection!.start();
    // ignore: avoid_print
    print('[WalkTracking] Connected. Joining group walk-$sessionId');
    await _connection!.invoke(_joinMethod, args: [sessionId]);
    // ignore: avoid_print
    print('[WalkTracking] Joined group walk-$sessionId');
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
    _completedController.close();
    _errorController.close();
    _connection?.stop();
  }
}
