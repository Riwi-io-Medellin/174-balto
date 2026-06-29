import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/walk_tracking_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/walker_repository.dart';
import 'live_walk_state.dart';

class LiveWalkCubit extends Cubit<LiveWalkState> {
  LiveWalkCubit({
    required this.booking,
    required WalkerRepository walkerRepository,
    required PetRepository petRepository,
    required WalkTrackingService trackingService,
    required TokenStorage tokenStorage,
  })  : _walkerRepository = walkerRepository,
        _petRepository = petRepository,
        _trackingService = trackingService,
        _tokenStorage = tokenStorage,
        super(const LiveWalkInitial());

  final WalkBooking booking;
  final WalkerRepository _walkerRepository;
  final PetRepository _petRepository;
  final WalkTrackingService _trackingService;
  final TokenStorage _tokenStorage;

  StreamSubscription<LatLng>? _locationSub;
  Timer? _elapsedTimer;

  Future<void> start() async {
    emit(const LiveWalkConnecting());
    try {
      final sessionId = booking.walkSessionId;
      if (sessionId == null) {
        emit(const LiveWalkError(
          'The walk has not started yet. Ask the walker to start the walk, then refresh.',
        ));
        return;
      }

      final (walker, pet) = await (
        _walkerRepository.getWalkerDetail(booking.walkerId),
        _petRepository.getById(booking.petId),
      ).wait;

      emit(LiveWalkActive(
        walkerName: walker.name,
        walkerAvatarUrl: walker.avatarUrl ?? walker.imageUrl,
        walkerRating: walker.rating,
        petName: pet.name,
      ));

      final token = await _tokenStorage.readAccessToken() ?? '';
      await _trackingService.start(sessionId, token);
      _locationSub = _trackingService.locationStream.listen(_onLocation);

      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final s = state;
        if (s is LiveWalkActive) {
          emit(s.copyWith(elapsedSeconds: s.elapsedSeconds + 1));
        }
      });
    } catch (e) {
      emit(LiveWalkError(e.toString()));
    }
  }

  void _onLocation(LatLng position) {
    final s = state;
    if (s is! LiveWalkActive) return;
    final updatedPoints = [...s.routePoints, position];
    emit(s.copyWith(
      currentPosition: position,
      routePoints: updatedPoints,
      distanceKm: _calcDistanceKm(updatedPoints),
      lastUpdateAt: DateTime.now(),
    ));
  }

  double _calcDistanceKm(List<LatLng> points) {
    if (points.length < 2) return 0;
    double total = 0;
    for (var i = 0; i < points.length - 1; i++) {
      total += _haversineMeters(points[i], points[i + 1]);
    }
    return total / 1000;
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

  Future<void> retry() => start();

  @override
  Future<void> close() async {
    _elapsedTimer?.cancel();
    _locationSub?.cancel();
    if (booking.walkSessionId != null) {
      await _trackingService.stop(booking.walkSessionId!);
    }
    _trackingService.dispose();
    return super.close();
  }
}
