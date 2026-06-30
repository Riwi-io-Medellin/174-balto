import 'dart:async';

import 'package:geolocator/geolocator.dart';

class WalkerLiveWalkService {
  StreamSubscription<Position>? _positionSub;
  final _positionController = StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionController.stream;

  Future<void> start() async {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_positionController.add);
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
