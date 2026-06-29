import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/walker_live_walk_service.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../../domain/repositories/walk_session_repository.dart';
import 'walker_live_walk_state.dart';

class WalkerLiveWalkCubit extends Cubit<WalkerLiveWalkState> {
  WalkerLiveWalkCubit({
    required this.booking,
    required WalkSessionRepository walkSessionRepository,
    required WalkerLiveWalkService liveWalkService,
  })  : _sessionRepository = walkSessionRepository,
        _liveWalkService = liveWalkService,
        super(const WalkerLiveWalkInitial());

  final WalkBooking booking;
  final WalkSessionRepository _sessionRepository;
  final WalkerLiveWalkService _liveWalkService;

  String? _sessionId;
  LatLng? _lastPosition;
  double _accumulatedDistanceMeters = 0;

  StreamSubscription<Position>? _positionSub;
  Timer? _elapsedTimer;

  Future<void> start() async {
    emit(const WalkerLiveWalkStarting());
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(const WalkerLiveWalkError(
          'Location permission is required to start the walk.',
        ));
        return;
      }

      _sessionId = await _sessionRepository.startSession(booking.id);

      await _liveWalkService.start();

      emit(const WalkerLiveWalkActive());

      _positionSub = _liveWalkService.positionStream.listen(_onPosition);

      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final s = state;
        if (s is WalkerLiveWalkActive) {
          emit(s.copyWith(elapsedSeconds: s.elapsedSeconds + 1));
        }
      });
    } catch (e) {
      emit(WalkerLiveWalkError(e.toString()));
    }
  }

  void _onPosition(Position position) {
    final s = state;
    if (s is! WalkerLiveWalkActive) return;

    final current = LatLng(position.latitude, position.longitude);
    if (_lastPosition != null) {
      _accumulatedDistanceMeters +=
          _haversineMeters(_lastPosition!, current);
    }
    _lastPosition = current;

    emit(s.copyWith(
      currentPosition: current,
      accuracyMeters: position.accuracy,
    ));

    final id = _sessionId;
    if (id != null) {
      _sessionRepository
          .addLocation(id, position.latitude, position.longitude)
          .catchError((_) {});
    }
  }

  double _haversineMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(a.latitude * math.pi / 180) *
            math.cos(b.latitude * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  Future<void> endWalk() async {
    _elapsedTimer?.cancel();
    await _positionSub?.cancel();
    final elapsedSeconds = state is WalkerLiveWalkActive
        ? (state as WalkerLiveWalkActive).elapsedSeconds
        : 0;
    emit(const WalkerLiveWalkEnding());
    try {
      await _liveWalkService.stop();
      if (_sessionId != null) {
        await _sessionRepository.finishSession(
          _sessionId!,
          _accumulatedDistanceMeters,
          elapsedSeconds,
        );
      }
      emit(const WalkerLiveWalkCompleted());
    } catch (e) {
      emit(WalkerLiveWalkError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    _elapsedTimer?.cancel();
    _positionSub?.cancel();
    _liveWalkService.dispose();
    return super.close();
  }
}
