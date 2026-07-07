import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/token_storage.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../domain/entities/business.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../../domain/entities/walker_profile.dart';
import '../../../domain/repositories/business_repository.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/walk_booking_repository.dart';
import '../../../domain/repositories/walker_profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._userRepository,
    required this._tokenStorage,
    required this._petRepository,
    required this._walkBookingRepository,
    required this._walkerProfileRepository,
    required this._businessRepository,
    required this._notificationRepository,
  }) : super(const ProfileInitial());

  final UserRepository _userRepository;
  final TokenStorage _tokenStorage;
  final PetRepository _petRepository;
  final WalkBookingRepository _walkBookingRepository;
  final WalkerProfileRepository _walkerProfileRepository;
  final BusinessRepository _businessRepository;
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
      final bookingsFuture = _walkBookingRepository.getMyBookings(
        status: 'completed',
      );
      final walkerProfileFuture = _walkerProfileRepository.getMyProfile();
      final businessProfileFuture = _businessRepository.getMyBusiness();
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
      final businessProfile = await _safeAwait<Business?>(
        businessProfileFuture,
        onError: (_) => null,
      );
      final unreadCount = await _safeAwait<int>(
        unreadCountFuture,
        onError: (_) => 0,
      );

      emit(
        ProfileLoaded(
          user: user,
          pets: savedPets,
          walkCount: completedBookings.length,
          walkerProfile: walkerProfile,
          businessProfile: businessProfile,
          unreadNotificationCount: unreadCount,
        ),
      );
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

  Future<void> reportLost({
    required String petId,
    required double lostLatitude,
    required double lostLongitude,
  }) async {
    final updated = await _petRepository.reportLost(
      id: petId,
      lostLatitude: lostLatitude,
      lostLongitude: lostLongitude,
    );
    _replacePet(updated);
  }

  Future<void> markFound(String petId) async {
    final updated = await _petRepository.markFound(petId);
    _replacePet(updated);
  }

  void _replacePet(Pet updated) {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(
      ProfileLoaded(
        user: current.user,
        pets: [
          for (final p in current.pets)
            if (p.id == updated.id) updated else p,
        ],
        walkCount: current.walkCount,
        walkerProfile: current.walkerProfile,
        businessProfile: current.businessProfile,
        unreadNotificationCount: current.unreadNotificationCount,
      ),
    );
  }
}
