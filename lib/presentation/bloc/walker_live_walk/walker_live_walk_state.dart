import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  });

  final LatLng? currentPosition;
  final double? accuracyMeters;
  final int elapsedSeconds;

  WalkerLiveWalkActive copyWith({
    LatLng? currentPosition,
    double? accuracyMeters,
    int? elapsedSeconds,
  }) =>
      WalkerLiveWalkActive(
        currentPosition: currentPosition ?? this.currentPosition,
        accuracyMeters: accuracyMeters ?? this.accuracyMeters,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );

  @override
  List<Object?> get props => [currentPosition, accuracyMeters, elapsedSeconds];
}

class WalkerLiveWalkEnding extends WalkerLiveWalkState {
  const WalkerLiveWalkEnding();
  @override
  List<Object?> get props => [];
}

class WalkerLiveWalkCompleted extends WalkerLiveWalkState {
  const WalkerLiveWalkCompleted();
  @override
  List<Object?> get props => [];
}

class WalkerLiveWalkError extends WalkerLiveWalkState {
  const WalkerLiveWalkError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
