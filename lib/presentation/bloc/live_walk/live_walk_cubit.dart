import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/active_session_tracker.dart';
import '../../../core/services/walk_tracking_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/walk_booking_repository.dart';
import '../../../domain/repositories/walk_session_repository.dart';
import '../../../domain/repositories/walker_repository.dart';
import 'live_walk_state.dart';

class LiveWalkCubit extends Cubit<LiveWalkState> {
  LiveWalkCubit({
    required this.booking,
    required this._walkerRepository,
    required this._petRepository,
    required this._trackingService,
    required this._tokenStorage,
    required WalkBookingRepository walkBookingRepository,
    required WalkSessionRepository walkSessionRepository,
  }) : _bookingRepository = walkBookingRepository,
       _sessionRepository = walkSessionRepository,
       super(const LiveWalkInitial());

  final WalkBooking booking;
  final WalkerRepository _walkerRepository;
  final PetRepository _petRepository;
  final WalkTrackingService _trackingService;
  final TokenStorage _tokenStorage;
  final WalkBookingRepository _bookingRepository;
  final WalkSessionRepository _sessionRepository;

  String? _resolvedSessionId;
  StreamSubscription<LatLng>? _locationSub;
  StreamSubscription<void>? _completedSub;
  StreamSubscription<String>? _errorSub;
  Timer? _elapsedTimer;
  Timer? _pollTimer;
  Timer? _completionPollTimer;

  Future<void> start() async {
    emit(const LiveWalkConnecting());
    try {
      // Always fetch fresh data — the booking passed in may be stale.
      final sid = await _fetchCurrentSessionId();
      if (isClosed) return;
      if (sid != null) {
        await _connectToSession(sid);
      } else {
        emit(const LiveWalkWaiting());
        _startPolling();
      }
    } catch (e) {
      if (isClosed) return;
      emit(LiveWalkError(e.toString()));
    }
  }

  Future<String?> _fetchCurrentSessionId() async {
    try {
      // Fetch without status filter to get the booking in any state (accepted
      // or in_progress — backend sets "in_progress" once the walk starts).
      final bookings = await _bookingRepository.getMyBookings();
      final fresh = bookings.cast<WalkBooking?>().firstWhere(
        (b) => b?.id == booking.id,
        orElse: () => null,
      );
      return fresh?.walkSessionId;
    } catch (_) {
      return booking.walkSessionId; // fall back to what we have
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _checkForSession(),
    );
  }

  Future<void> _checkForSession() async {
    if (state is! LiveWalkWaiting) return;
    try {
      final sid = await _fetchCurrentSessionId();
      if (isClosed) return;
      if (sid != null) {
        _pollTimer?.cancel();
        _pollTimer = null;
        await _connectToSession(sid);
      }
    } catch (_) {}
  }

  Future<void> _connectToSession(String sessionId) async {
    _resolvedSessionId = sessionId;

    final (walker, pet) = await (
      _walkerRepository.getWalkerDetail(booking.walkerId),
      _petRepository.getById(booking.petId),
    ).wait;
    if (isClosed) return;

    emit(
      LiveWalkActive(
        walkerName: walker.name,
        walkerAvatarUrl: walker.avatarUrl ?? walker.imageUrl,
        walkerRating: walker.rating,
        petName: pet.name,
        sessionId: sessionId,
      ),
    );
    ActiveSessionTracker.enter(sessionId);

    final token = await _tokenStorage.readAccessToken() ?? '';
    await _trackingService.start(sessionId, token);
    _locationSub = _trackingService.locationStream.listen(_onLocation);
    _completedSub = _trackingService.walkCompletedStream.listen(
      _onWalkCompleted,
    );
    _errorSub = _trackingService.errorStream.listen((msg) {
      emit(LiveWalkError('Could not join walk group: $msg'));
    });

    // Pre-seed the map with already-recorded route points so the walker's
    // position is visible immediately without waiting for the next live update.
    _seedRouteFromHistory(sessionId);

    // Fallback: poll for booking completion in case backend doesn't emit SignalR event
    _completionPollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _pollForCompletion(),
    );

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is LiveWalkActive) {
        emit(s.copyWith(elapsedSeconds: s.elapsedSeconds + 1));
      }
    });
  }

  Future<void> _seedRouteFromHistory(String sessionId) async {
    try {
      final points = await _sessionRepository.getRoute(sessionId);
      if (points.isEmpty || isClosed) return;
      final s = state;
      if (s is! LiveWalkActive) return;
      final last = points.last;
      emit(
        s.copyWith(
          currentPosition: last,
          routePoints: points,
          distanceKm: _calcDistanceKm(points),
        ),
      );
    } catch (_) {}
  }

  Future<void> _pollForCompletion() async {
    if (state is! LiveWalkActive) return;
    try {
      final bookings = await _bookingRepository.getMyBookings(
        status: 'completed',
      );
      final finished = bookings.cast<WalkBooking?>().firstWhere(
        (b) => b?.id == booking.id,
        orElse: () => null,
      );
      if (finished != null) {
        final Map<String, dynamic> payload = {};
        if (finished.actualDistanceMeters != null) {
          payload['distanceMeters'] = finished.actualDistanceMeters;
        }
        if (finished.actualDurationSeconds != null) {
          payload['durationSeconds'] = finished.actualDurationSeconds;
        }
        _onWalkCompleted(payload.isEmpty ? null : payload);
      }
    } catch (_) {}
  }

  void _onWalkCompleted([Map<String, dynamic>? payload]) {
    if (isClosed) return;
    final s = state;
    _elapsedTimer?.cancel();
    _locationSub?.cancel();
    _completedSub?.cancel();
    _errorSub?.cancel();
    _completionPollTimer?.cancel();
    if (s is LiveWalkActive) {
      final distanceKm = payload != null
          ? ((payload['distanceMeters'] as num?)?.toDouble() ?? 0) / 1000
          : s.distanceKm;
      final elapsedSeconds = payload != null
          ? (payload['durationSeconds'] as int?) ?? s.elapsedSeconds
          : s.elapsedSeconds;
      emit(
        LiveWalkCompleted(
          sessionId: _resolvedSessionId ?? booking.walkSessionId ?? '',
          distanceKm: distanceKm,
          elapsedSeconds: elapsedSeconds,
        ),
      );
    }
  }

  void _onLocation(LatLng position) {
    final s = state;
    if (s is! LiveWalkActive) return;
    final updatedPoints = [...s.routePoints, position];
    emit(
      s.copyWith(
        currentPosition: position,
        routePoints: updatedPoints,
        distanceKm: _calcDistanceKm(updatedPoints),
        lastUpdateAt: DateTime.now(),
      ),
    );
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
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
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
    _pollTimer?.cancel();
    _completionPollTimer?.cancel();
    _locationSub?.cancel();
    _completedSub?.cancel();
    _errorSub?.cancel();
    final sid = _resolvedSessionId ?? booking.walkSessionId;
    if (sid != null) {
      await _trackingService.stop(sid);
      ActiveSessionTracker.leave(sid);
    }
    _trackingService.dispose();
    return super.close();
  }
}
