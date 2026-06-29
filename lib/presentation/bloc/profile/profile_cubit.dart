import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/token_storage.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/walker_profile.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/walker_profile_repository.dart';
import '../../../domain/repositories/walking_history_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required UserRepository userRepository,
    required TokenStorage tokenStorage,
    required PetRepository petRepository,
    required WalkingHistoryRepository walkingHistoryRepository,
    required WalkerProfileRepository walkerProfileRepository,
  // ignore: prefer_initializing_formals
  })  : _userRepository = userRepository,
        _tokenStorage = tokenStorage,
        _petRepository = petRepository,
        _walkingHistoryRepository = walkingHistoryRepository,
        _walkerProfileRepository = walkerProfileRepository,
        super(const ProfileInitial());

  final UserRepository _userRepository;
  final TokenStorage _tokenStorage;
  final PetRepository _petRepository;
  final WalkingHistoryRepository _walkingHistoryRepository;
  final WalkerProfileRepository _walkerProfileRepository;

  Future<void> load() async {
    emit(const ProfileLoading());
    try {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken == null) {
        emit(const ProfileError('NO_TOKEN', 'No active session.'));
        return;
      }
      final userId = JwtDecoder.extractUserId(accessToken);
      if (userId == null) {
        emit(const ProfileError('INVALID_TOKEN', 'Token has no user id.'));
        return;
      }

      // Fire all requests concurrently.
      final userFuture = _userRepository.getById(userId);
      final petsFuture = _petRepository.getMyPets();
      final walkCountFuture = _walkingHistoryRepository.getMyWalkCount();
      // Walker profile may fail without blocking profile.
      final walkerProfileFuture = _walkerProfileRepository.getMyProfile();

      // User is required — fail if this fails.
      final User user = await userFuture;
      final savedPets = await _safeAwait<List<Pet>>(
        petsFuture,
        onError: (_) => <Pet>[],
      );
      final walkCount = await _safeAwait<int>(
        walkCountFuture,
        onError: (_) => 0,
      );
      final walkerProfile = await _safeAwait<WalkerProfile?>(
        walkerProfileFuture,
        onError: (_) => null,
      );

      emit(ProfileLoaded(
        user: user,
        pets: savedPets,
        walkCount: walkCount,
        averageRating: 0.0,
        walkerProfile: walkerProfile,
      ));
    } on UserFailure catch (e) {
      emit(ProfileError(e.code, e.message));
    } on FormatException catch (e) {
      emit(ProfileError('INVALID_TOKEN', e.message));
    } catch (e) {
      emit(ProfileError('UNKNOWN', e.toString()));
    }
  }

  /// Awaits a future and returns [onError]'s fallback on failure,
  /// preventing unhandled exceptions from concurrent futures.
  Future<T> _safeAwait<T>(
    Future<T> future, {
    required T Function(Object) onError,
  }) async {
    try {
      return await future;
    } catch (e) {
      return onError(e);
    }
  }
}
