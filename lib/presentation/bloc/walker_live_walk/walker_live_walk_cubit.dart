import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/active_session_tracker.dart';
import '../../../core/services/walker_live_walk_service.dart';
import '../../../data/datasources/upload_remote_datasource.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../../domain/entities/walk_media.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../../domain/repositories/walk_session_repository.dart';
import 'walker_live_walk_state.dart';

class WalkerLiveWalkCubit extends Cubit<WalkerLiveWalkState> {
  WalkerLiveWalkCubit({
    required this.booking,
    required WalkSessionRepository walkSessionRepository,
    required this._liveWalkService,
    required this._uploadRepository,
  }) : _sessionRepository = walkSessionRepository,
       super(const WalkerLiveWalkInitial());

  final WalkBooking booking;
  final WalkSessionRepository _sessionRepository;
  final WalkerLiveWalkService _liveWalkService;
  final UploadRepository _uploadRepository;
  final ImagePicker _picker = ImagePicker();

  String? _sessionId;
  LatLng? _lastPosition;
  double _accumulatedDistanceMeters = 0;

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<String>? _errorSub;
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
        emit(
          const WalkerLiveWalkError(
            'Location permission is required to start the walk.',
          ),
        );
        return;
      }

      // Rejoin existing session if the walk is already in progress.
      final existingId = booking.walkSessionId;
      if (existingId != null) {
        _sessionId = existingId;
      } else {
        _sessionId = await _sessionRepository.startSession(booking.id);
      }
      // ignore: avoid_print
      print(
        '[WalkerLive] Session ID: $_sessionId (rejoined: ${existingId != null})',
      );

      await _liveWalkService.start();
      if (isClosed) return;

      emit(WalkerLiveWalkActive(sessionId: _sessionId));
      if (_sessionId != null) ActiveSessionTracker.enter(_sessionId!);

      _positionSub = _liveWalkService.positionStream.listen(_onPosition);
      _errorSub = _liveWalkService.errorStream.listen((msg) {
        final s = state;
        // Only surface as a blocking error while still waiting for the first
        // fix — once the walk is actively tracking, a transient stream error
        // shouldn't tear down an otherwise-working session.
        if (s is WalkerLiveWalkActive && s.currentPosition == null) {
          emit(WalkerLiveWalkError('Could not get your location: $msg'));
        }
      });

      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final s = state;
        if (s is WalkerLiveWalkActive) {
          emit(s.copyWith(elapsedSeconds: s.elapsedSeconds + 1));
        }
      });
    } catch (e) {
      if (isClosed) return;
      final message = e is LocationServiceDisabledException
          ? 'Please turn on device location (GPS) and try again.'
          : e.toString();
      emit(WalkerLiveWalkError(message));
    }
  }

  void _onPosition(Position position) {
    // ignore: avoid_print
    print(
      '[WalkerLive] GPS fix: ${position.latitude}, ${position.longitude} acc=${position.accuracy}m',
    );
    final s = state;
    if (s is! WalkerLiveWalkActive) return;

    final current = LatLng(position.latitude, position.longitude);
    if (_lastPosition != null) {
      _accumulatedDistanceMeters += _haversineMeters(_lastPosition!, current);
    }
    _lastPosition = current;

    final updatedPoints = [...s.routePoints, current];

    emit(
      s.copyWith(
        currentPosition: current,
        accuracyMeters: position.accuracy,
        routePoints: updatedPoints,
        distanceKm: _accumulatedDistanceMeters / 1000,
      ),
    );

    final id = _sessionId;
    if (id != null) {
      _sessionRepository
          .addLocation(id, position.latitude, position.longitude)
          // ignore: avoid_print
          .catchError((e) => print('[WalkerLive] addLocation error: $e'));
    }
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

  static const int _maxVideoBytes = 50 * 1024 * 1024; // 50 MB

  Future<void> captureAndUploadMedia({
    required ImageSource source,
    required bool isVideo,
  }) async {
    final s = state;
    if (s is! WalkerLiveWalkActive || _sessionId == null) return;
    emit(s.copyWith(isUploadingMedia: true, clearMediaError: true));
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(
              source: source,
              maxDuration: const Duration(seconds: 60),
            )
          : await _picker.pickImage(source: source, imageQuality: 80);

      if (file == null) {
        final cur = state;
        if (cur is WalkerLiveWalkActive) {
          emit(cur.copyWith(isUploadingMedia: false));
        }
        return;
      }

      if (isVideo) {
        final size = await File(file.path).length();
        if (size > _maxVideoBytes) {
          final cur = state;
          if (cur is WalkerLiveWalkActive) {
            emit(
              cur.copyWith(
                isUploadingMedia: false,
                mediaUploadError:
                    'Video is too large (max 50 MB). Please record a shorter clip.',
              ),
            );
          }
          return;
        }
      }

      final filename = isVideo
          ? 'walk_video_${file.name}'
          : 'walk_photo_${file.name}';
      final url = await _uploadRepository.uploadFile(file.path, filename);
      final type = isVideo ? 'video' : 'photo';
      await _sessionRepository.addMedia(_sessionId!, url, type);
      final current = state;
      if (current is WalkerLiveWalkActive) {
        final newItem = WalkMedia(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          url: url,
          type: type,
          uploadedAt: DateTime.now(),
        );
        emit(
          current.copyWith(
            mediaItems: [...current.mediaItems, newItem],
            isUploadingMedia: false,
          ),
        );
      }
    } on UploadFailure catch (e) {
      final current = state;
      if (current is WalkerLiveWalkActive) {
        emit(
          current.copyWith(
            isUploadingMedia: false,
            mediaUploadError: e.message,
          ),
        );
      }
    } on UploadRemoteFailure catch (e) {
      final current = state;
      if (current is WalkerLiveWalkActive) {
        emit(
          current.copyWith(
            isUploadingMedia: false,
            mediaUploadError: e.message,
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('[WalkerLive] media upload error: $e');
      final current = state;
      if (current is WalkerLiveWalkActive) {
        emit(
          current.copyWith(
            isUploadingMedia: false,
            mediaUploadError: 'Upload failed. Please try again.',
          ),
        );
      }
    }
  }

  void clearMediaUploadError() {
    final s = state;
    if (s is WalkerLiveWalkActive) emit(s.copyWith(clearMediaError: true));
  }

  Future<void> endWalk() async {
    _elapsedTimer?.cancel();
    await _positionSub?.cancel();
    await _errorSub?.cancel();
    final activeState = state is WalkerLiveWalkActive
        ? state as WalkerLiveWalkActive
        : null;
    final elapsedSeconds = activeState?.elapsedSeconds ?? 0;
    final distanceKm = _accumulatedDistanceMeters / 1000;
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
      if (isClosed) return;
      emit(
        WalkerLiveWalkCompleted(
          sessionId: _sessionId ?? '',
          distanceKm: distanceKm,
          elapsedSeconds: elapsedSeconds,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(WalkerLiveWalkError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    _elapsedTimer?.cancel();
    _positionSub?.cancel();
    _errorSub?.cancel();
    _liveWalkService.dispose();
    if (_sessionId != null) ActiveSessionTracker.leave(_sessionId!);
    return super.close();
  }
}
