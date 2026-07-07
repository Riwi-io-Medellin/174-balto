import 'package:equatable/equatable.dart';

import '../../../domain/entities/home_service_provider.dart';

abstract class HomeServiceState extends Equatable {
  const HomeServiceState();

  @override
  List<Object?> get props => const [];
}

class HomeServiceInitial extends HomeServiceState {
  const HomeServiceInitial();
}

class HomeServiceLoading extends HomeServiceState {
  const HomeServiceLoading();
}

class HomeServiceLoadingMore extends HomeServiceState {
  const HomeServiceLoadingMore({
    required this.providers,
    this.selectedFilter = 0,
  });

  final List<HomeServiceProvider> providers;
  final int selectedFilter;

  @override
  List<Object?> get props => [providers, selectedFilter];
}

class HomeServiceListLoaded extends HomeServiceState {
  const HomeServiceListLoaded({
    required this.providers,
    this.selectedFilter = 0,
    this.hasMore = false,
  });

  final List<HomeServiceProvider> providers;
  final int selectedFilter;
  final bool hasMore;

  @override
  List<Object?> get props => [providers, selectedFilter, hasMore];
}

class HomeServiceDetailLoaded extends HomeServiceState {
  const HomeServiceDetailLoaded(this.provider);

  final HomeServiceProvider provider;

  @override
  List<Object?> get props => [provider];
}

class HomeServiceError extends HomeServiceState {
  const HomeServiceError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
