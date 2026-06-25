import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/token_storage.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/walking_history_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required UserRepository userRepository,
    required TokenStorage tokenStorage,
    required PetRepository petRepository,
    required WalkingHistoryRepository walkingHistoryRepository,
  })  : _userRepository = userRepository,
        _tokenStorage = tokenStorage,
        _petRepository = petRepository,
        _walkingHistoryRepository = walkingHistoryRepository,
        super(const ProfileInitial());

  final UserRepository _userRepository;
  final TokenStorage _tokenStorage;
  final PetRepository _petRepository;
  final WalkingHistoryRepository _walkingHistoryRepository;

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

      final userFuture = _userRepository.getById(userId);
      final petsFuture = _petRepository.getMyPets();
      final walkCountFuture = _walkingHistoryRepository.getMyWalkCount();

      final user = await userFuture;
      final pets = await petsFuture;
      final walkCount = await walkCountFuture;

      // Calculate average rating from feedback (stub for now)
      const averageRating = 0.0;

      emit(ProfileLoaded(
        user: user,
        pets: pets.cast(),
        walkCount: walkCount,
        averageRating: averageRating,
      ));
    } on UserFailure catch (e) {
      emit(ProfileError(e.code, e.message));
    } on FormatException catch (e) {
      emit(ProfileError('INVALID_TOKEN', e.message));
    } catch (e) {
      emit(ProfileError('UNKNOWN', e.toString()));
    }
  }
}
