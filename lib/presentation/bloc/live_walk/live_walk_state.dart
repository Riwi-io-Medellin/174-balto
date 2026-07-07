import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LiveWalkState extends Equatable {
  const LiveWalkState();
}

class LiveWalkInitial extends LiveWalkState {
  const LiveWalkInitial();
  @override
  List<Object?> get props => [];
}

class LiveWalkConnecting extends LiveWalkState {
  const LiveWalkConnecting();
  @override
  List<Object?> get props => [];
}

// Walker hasn't started the walk yet — polling until walkSessionId is set
class LiveWalkWaiting extends LiveWalkState {
  const LiveWalkWaiting();
  @override
  List<Object?> get props => [];
}

class LiveWalkActive extends LiveWalkState {
  const LiveWalkActive({
    required this.walkerName,
    required this.walkerAvatarUrl,
    required this.walkerRating,
    required this.petName,
    this.sessionId,
    this.currentPosition,
    this.routePoints = const [],
    this.elapsedSeconds = 0,
    this.distanceKm = 0.0,
    this.lastUpdateAt,
  });

  final String walkerName;
  final String walkerAvatarUrl;
  final double walkerRating;
  final String petName;
  final String? sessionId;
  final LatLng? currentPosition;
  final List<LatLng> routePoints;
  final int elapsedSeconds;
  final double distanceKm;
  final DateTime? lastUpdateAt;

  LiveWalkActive copyWith({
    LatLng? currentPosition,
    List<LatLng>? routePoints,
    int? elapsedSeconds,
    double? distanceKm,
    DateTime? lastUpdateAt,
  }) => LiveWalkActive(
    walkerName: walkerName,
    walkerAvatarUrl: walkerAvatarUrl,
    walkerRating: walkerRating,
    petName: petName,
    sessionId: sessionId,
    currentPosition: currentPosition ?? this.currentPosition,
    routePoints: routePoints ?? this.routePoints,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    distanceKm: distanceKm ?? this.distanceKm,
    lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
  );

  @override
  List<Object?> get props => [
    walkerName,
    walkerAvatarUrl,
    walkerRating,
    petName,
    sessionId,
    currentPosition,
    routePoints,
    elapsedSeconds,
    distanceKm,
    lastUpdateAt,
  ];
}

class LiveWalkCompleted extends LiveWalkState {
  const LiveWalkCompleted({
    required this.sessionId,
    required this.distanceKm,
    required this.elapsedSeconds,
  });

  final String sessionId;
  final double distanceKm;
  final int elapsedSeconds;

  @override
  List<Object?> get props => [sessionId, distanceKm, elapsedSeconds];
}

class LiveWalkError extends LiveWalkState {
  const LiveWalkError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
