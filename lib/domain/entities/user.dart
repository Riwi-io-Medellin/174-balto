import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.idNumber,
    required this.idType,
    required this.phone,
    this.phoneExtra,
    this.location,
    this.address,
    this.photoUrl,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String idNumber;
  final String idType;
  final String phone;
  final String? phoneExtra;
  final String? location;
  final String? address;
  final String? photoUrl;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    idNumber,
    idType,
    phone,
    phoneExtra,
    location,
    address,
    photoUrl,
    createdAt,
    latitude,
    longitude,
  ];
}
