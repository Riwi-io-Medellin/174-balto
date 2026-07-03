import 'package:equatable/equatable.dart';

import '../../../domain/entities/business.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object?> get props => const [];
}

class BusinessInitial extends BusinessState {
  const BusinessInitial();
}

class BusinessLoading extends BusinessState {
  const BusinessLoading();
}

class BusinessListLoaded extends BusinessState {
  const BusinessListLoaded(this.businesses);

  final List<Business> businesses;

  @override
  List<Object?> get props => [businesses];
}

class BusinessDetailLoaded extends BusinessState {
  const BusinessDetailLoaded(this.business);

  final Business business;

  @override
  List<Object?> get props => [business];
}

class BusinessError extends BusinessState {
  const BusinessError(this.code, this.message);

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
