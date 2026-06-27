import 'package:equatable/equatable.dart';

import '../../../domain/entities/me.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/user.dart';

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
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isWalker = false,
    this.walkerId,
    this.walkerStatus,
    this.businesses = const [],
  });

  final User user;
  final List<Pet> pets;
  final int walkCount;
  final double averageRating;
  final int totalReviews;
  final bool isWalker;
  final String? walkerId;
  final String? walkerStatus;
  final List<BusinessSummary> businesses;

  int get petCount => pets.length;

  @override
  List<Object?> get props => [
        user,
        pets,
        walkCount,
        averageRating,
        totalReviews,
        isWalker,
        walkerId,
        walkerStatus,
        businesses,
      ];
}

class ProfileError extends ProfileState {
  const ProfileError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}

class ProfileSignedOut extends ProfileState {
  const ProfileSignedOut();
}
