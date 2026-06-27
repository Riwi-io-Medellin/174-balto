import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/token_storage.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../domain/entities/feedback_summary.dart';
import '../../../domain/entities/me.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/feedback_repository.dart';
import '../../../domain/repositories/me_repository.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/walker_repository.dart';
import '../../../domain/repositories/walking_history_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required UserRepository userRepository,
    required TokenStorage tokenStorage,
    required PetRepository petRepository,
    required WalkingHistoryRepository walkingHistoryRepository,
    required MeRepository meRepository,
    required WalkerRepository walkerRepository,
    required FeedbackRepository feedbackRepository,
    required AuthRepository authRepository,
    required UploadRepository uploadRepository,
  })  : _userRepository = userRepository,
        _tokenStorage = tokenStorage,
        _petRepository = petRepository,
        _walkingHistoryRepository = walkingHistoryRepository,
        _meRepository = meRepository,
        _walkerRepository = walkerRepository,
        _feedbackRepository = feedbackRepository,
        _authRepository = authRepository,
        _uploadRepository = uploadRepository,
        super(const ProfileInitial());

  final UserRepository _userRepository;
  final TokenStorage _tokenStorage;
  final PetRepository _petRepository;
  final WalkingHistoryRepository _walkingHistoryRepository;
  final MeRepository _meRepository;
  final WalkerRepository _walkerRepository;
  final FeedbackRepository _feedbackRepository;
  final AuthRepository _authRepository;
  final UploadRepository _uploadRepository;

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
      final meFuture = _safeMe();

      final user = await userFuture;
      final pets = await petsFuture;
      final walkCount = await walkCountFuture;
      final me = await meFuture;

      double averageRating = 0.0;
      int totalReviews = 0;
      String? walkerId;
      if (me != null && me.isWalker) {
        walkerId = await _resolveWalkerId(userId);
        if (walkerId != null) {
          final summary = await _safeFeedback(walkerId);
          if (summary != null) {
            averageRating = summary.averageRating;
            totalReviews = summary.totalReviews;
          }
        }
      }

      emit(ProfileLoaded(
        user: user,
        pets: pets.cast(),
        walkCount: walkCount,
        averageRating: averageRating,
        totalReviews: totalReviews,
        isWalker: me?.isWalker ?? false,
        walkerId: walkerId,
        walkerStatus: me?.walkerStatus,
        businesses: me?.businesses ?? const <BusinessSummary>[],
      ));
    } on UserFailure catch (e) {
      emit(ProfileError(e.code, e.message));
    } on FormatException catch (e) {
      emit(ProfileError('INVALID_TOKEN', e.message));
    } catch (e) {
      emit(ProfileError('UNKNOWN', e.toString()));
    }
  }

  Future<Me?> _safeMe() async {
    try {
      return await _meRepository.get();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveWalkerId(String userId) async {
    try {
      final walker = await _walkerRepository.findByUserId(userId);
      return walker?.id;
    } catch (_) {
      return null;
    }
  }

  Future<FeedbackSummary?> _safeFeedback(String walkerId) async {
    try {
      return await _feedbackRepository.getByWalker(walkerId);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    emit(const ProfileLoading());
    try {
      await _authRepository.logout();
      emit(const ProfileSignedOut());
    } catch (e) {
      emit(ProfileError('LOGOUT_FAILED', e.toString()));
    }
  }

  Future<void> updateAvatar(String filePath) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final photoUrl = await _uploadRepository.uploadImage(filePath);
    await _userRepository.update(
      id: currentState.user.id,
      firstName: currentState.user.firstName,
      lastName: currentState.user.lastName,
      idNumber: currentState.user.idNumber,
      idType: currentState.user.idType,
      phone: currentState.user.phone,
      phoneExtra: currentState.user.phoneExtra,
      address: currentState.user.address,
      location: currentState.user.location,
      photoUrl: photoUrl,
    );
    await load();
  }
}
