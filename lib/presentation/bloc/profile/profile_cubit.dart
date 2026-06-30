import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/token_storage.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../../domain/entities/walker_profile.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/walk_booking_repository.dart';
import '../../../domain/repositories/walker_profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required UserRepository userRepository,
    required TokenStorage tokenStorage,
    required PetRepository petRepository,
    required WalkBookingRepository walkBookingRepository,
    required WalkerProfileRepository walkerProfileRepository,
    required NotificationRepository notificationRepository,
  })  : _userRepository = userRepository,
        _tokenStorage = tokenStorage,
        _petRepository = petRepository,
        _walkBookingRepository = walkBookingRepository,
        _walkerProfileRepository = walkerProfileRepository,
        _notificationRepository = notificationRepository,
        super(const ProfileInitial());

  final UserRepository _userRepository;
  final TokenStorage _tokenStorage;
  final PetRepository _petRepository;
  final WalkBookingRepository _walkBookingRepository;
  final WalkerProfileRepository _walkerProfileRepository;
  final NotificationRepository _notificationRepository;

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
      final bookingsFuture = _walkBookingRepository.getMyBookings(status: 'completed');
      final walkerProfileFuture = _walkerProfileRepository.getMyProfile();
      final unreadCountFuture = _notificationRepository.getUnreadCount();

      final User user = await userFuture;
      final savedPets = await _safeAwait<List<Pet>>(
        petsFuture,
        onError: (_) => <Pet>[],
      );
      final completedBookings = await _safeAwait<List<WalkBooking>>(
        bookingsFuture,
        onError: (_) => <WalkBooking>[],
      );
      final walkerProfile = await _safeAwait<WalkerProfile?>(
        walkerProfileFuture,
        onError: (_) => null,
      );
      final unreadCount = await _safeAwait<int>(
        unreadCountFuture,
        onError: (_) => 0,
      );

      emit(ProfileLoaded(
        user: user,
        pets: savedPets,
        walkCount: completedBookings.length,
        walkerProfile: walkerProfile,
        unreadNotificationCount: unreadCount,
      ));
    } on UserFailure catch (e) {
      emit(ProfileError(e.code, e.message));
    } on FormatException catch (e) {
      emit(ProfileError('INVALID_TOKEN', e.message));
    } catch (e) {
      emit(ProfileError('UNKNOWN', e.toString()));
    }
  }

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
