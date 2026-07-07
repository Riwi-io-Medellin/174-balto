import 'package:equatable/equatable.dart';

class BusinessSummary extends Equatable {
  const BusinessSummary({
    required this.id,
    required this.name,
    this.type,
    required this.verificationStatus,
  });

  final String id;
  final String name;
  final String? type;
  final String verificationStatus;

  @override
  List<Object?> get props => [id, name, type, verificationStatus];
}

class Me extends Equatable {
  const Me({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isWalker,
    this.walkerStatus,
    this.businesses = const [],
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final bool isWalker;
  final String? walkerStatus;
  final List<BusinessSummary> businesses;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    isWalker,
    walkerStatus,
    businesses,
  ];
}
