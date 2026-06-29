import 'package:equatable/equatable.dart';

import '../../../domain/entities/walker.dart';

abstract class WalkerState extends Equatable {
  const WalkerState();

  @override
  List<Object?> get props => const [];
}

class WalkerInitial extends WalkerState {
  const WalkerInitial();
}

class WalkerLoading extends WalkerState {
  const WalkerLoading();
}

class WalkerLoadingMore extends WalkerState {
  const WalkerLoadingMore({required this.walkers, this.selectedFilter = 0});

  final List<Walker> walkers;
  final int selectedFilter;

  @override
  List<Object?> get props => [walkers, selectedFilter];
}

class WalkerListLoaded extends WalkerState {
  const WalkerListLoaded({
    required this.walkers,
    this.selectedFilter = 0,
    this.hasMore = false,
  });

  final List<Walker> walkers;
  final int selectedFilter;
  final bool hasMore;

  @override
  List<Object?> get props => [walkers, selectedFilter, hasMore];
}

class WalkerDetailLoaded extends WalkerState {
  const WalkerDetailLoaded(this.walker);

  final Walker walker;

  @override
  List<Object?> get props => [walker];
}

class WalkerError extends WalkerState {
  const WalkerError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
