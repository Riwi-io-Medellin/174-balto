import 'package:equatable/equatable.dart';

import '../../../domain/entities/home_provider_service_item.dart';
import '../../../domain/entities/home_service_type.dart';

abstract class HomeProviderServicesState extends Equatable {
  const HomeProviderServicesState();

  @override
  List<Object?> get props => [];
}

class HomeProviderServicesInitial extends HomeProviderServicesState {
  const HomeProviderServicesInitial();
}

class HomeProviderServicesLoading extends HomeProviderServicesState {
  const HomeProviderServicesLoading();
}

class HomeProviderServicesLoaded extends HomeProviderServicesState {
  const HomeProviderServicesLoaded({
    required this.services,
    required this.availableTypes,
  });

  final List<HomeProviderServiceItem> services;
  final List<HomeServiceType> availableTypes;

  @override
  List<Object?> get props => [services, availableTypes];
}

class HomeProviderServicesError extends HomeProviderServicesState {
  const HomeProviderServicesError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
