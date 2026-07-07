import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

class WalkerLiveWalkService {
  StreamSubscription<Position>? _positionSub;
  final _positionController = StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionController.stream;

  Future<void> start() async {
    final LocationSettings settings;

    if (Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        // Foreground service keeps GPS alive with screen locked.
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Balto — Walk in progress',
          notificationText: 'Recording your route in the background.',
          enableWakeLock: true,
          enableWifiLock: true,
        ),
      );
    } else {
      // iOS: UIBackgroundModes = location in Info.plist handles background.
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_positionController.add);
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  void dispose() {
    _positionSub?.cancel();
    _positionController.close();
  }
}
