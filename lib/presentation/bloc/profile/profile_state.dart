import 'package:equatable/equatable.dart';

import '../../../domain/entities/business.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/walker_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => const [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    this.pets = const [],
    this.walkCount = 0,
    this.walkerProfile,
    this.businessProfile,
    this.unreadNotificationCount = 0,
  });

  final User user;
  final List<Pet> pets;
  final int walkCount;

  /// null  => user has never applied to become a walker
  /// non-null => user has an application; check [walkerProfile.status]
  final WalkerProfile? walkerProfile;

  /// null  => user has never registered a business
  /// non-null => user has a business; check [businessProfile.verificationStatus]
  final Business? businessProfile;

  final int unreadNotificationCount;

  int get petCount => pets.length;

  @override
  List<Object?> get props => [
        user,
        pets,
        walkCount,
        walkerProfile,
        businessProfile,
        unreadNotificationCount,
      ];
}

class ProfileError extends ProfileState {
  const ProfileError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
