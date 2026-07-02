import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/entities/walk_media.dart';

abstract class WalkerLiveWalkState extends Equatable {
  const WalkerLiveWalkState();
}

class WalkerLiveWalkInitial extends WalkerLiveWalkState {
  const WalkerLiveWalkInitial();
  @override
  List<Object?> get props => [];
}

class WalkerLiveWalkStarting extends WalkerLiveWalkState {
  const WalkerLiveWalkStarting();
  @override
  List<Object?> get props => [];
}

class WalkerLiveWalkActive extends WalkerLiveWalkState {
  const WalkerLiveWalkActive({
    this.currentPosition,
    this.accuracyMeters,
    this.elapsedSeconds = 0,
    this.routePoints = const [],
    this.distanceKm = 0.0,
    this.mediaItems = const [],
    this.isUploadingMedia = false,
    this.mediaUploadError,
  });

  final LatLng? currentPosition;
  final double? accuracyMeters;
  final int elapsedSeconds;
  final List<LatLng> routePoints;
  final double distanceKm;
  final List<WalkMedia> mediaItems;
  final bool isUploadingMedia;
  final String? mediaUploadError;

  WalkerLiveWalkActive copyWith({
    LatLng? currentPosition,
    double? accuracyMeters,
    int? elapsedSeconds,
    List<LatLng>? routePoints,
    double? distanceKm,
    List<WalkMedia>? mediaItems,
    bool? isUploadingMedia,
    bool clearMediaError = false,
    String? mediaUploadError,
  }) =>
      WalkerLiveWalkActive(
        currentPosition: currentPosition ?? this.currentPosition,
        accuracyMeters: accuracyMeters ?? this.accuracyMeters,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        routePoints: routePoints ?? this.routePoints,
        distanceKm: distanceKm ?? this.distanceKm,
        mediaItems: mediaItems ?? this.mediaItems,
        isUploadingMedia: isUploadingMedia ?? this.isUploadingMedia,
        mediaUploadError: clearMediaError
            ? null
            : (mediaUploadError ?? this.mediaUploadError),
      );

  @override
  List<Object?> get props => [
        currentPosition,
        accuracyMeters,
        elapsedSeconds,
        routePoints,
        distanceKm,
        mediaItems,
        isUploadingMedia,
        mediaUploadError,
      ];
}

class WalkerLiveWalkEnding extends WalkerLiveWalkState {
  const WalkerLiveWalkEnding();
  @override
  List<Object?> get props => [];
}

class WalkerLiveWalkCompleted extends WalkerLiveWalkState {
  const WalkerLiveWalkCompleted({
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

class WalkerLiveWalkError extends WalkerLiveWalkState {
  const WalkerLiveWalkError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
