import 'package:equatable/equatable.dart';

class HomeProviderSpecialty extends Equatable {
  const HomeProviderSpecialty({required this.id, required this.specialty});

  final String id;
  final String specialty;

  @override
  List<Object?> get props => [id, specialty];
}
