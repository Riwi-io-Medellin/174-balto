import '../../domain/entities/user.dart';

class UserDto {
  UserDto({
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

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      idNumber: json['idNumber'] as String,
      idType: json['idType'] as String,
      phone: json['phone'] as String,
      phoneExtra: json['phoneExtra'] as String?,
      location: json['location'] as String?,
      address: json['address'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  User toEntity() => User(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    idNumber: idNumber,
    idType: idType,
    phone: phone,
    phoneExtra: phoneExtra,
    location: location,
    address: address,
    photoUrl: photoUrl,
    createdAt: createdAt,
    latitude: latitude,
    longitude: longitude,
  );
}
