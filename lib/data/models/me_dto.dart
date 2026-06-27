import '../../domain/entities/me.dart';

class BusinessSummaryDto {
  BusinessSummaryDto({
    required this.id,
    required this.name,
    this.type,
    required this.verificationStatus,
  });

  final String id;
  final String name;
  final String? type;
  final String verificationStatus;

  factory BusinessSummaryDto.fromJson(Map<String, dynamic> json) {
    return BusinessSummaryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String?,
      verificationStatus: json['verificationStatus'] as String,
    );
  }

  BusinessSummary toEntity() => BusinessSummary(
        id: id,
        name: name,
        type: type,
        verificationStatus: verificationStatus,
      );
}

class MeDto {
  MeDto({
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
  final List<BusinessSummaryDto> businesses;

  factory MeDto.fromJson(Map<String, dynamic> json) {
    final raw = json['businesses'] as List? ?? const [];
    return MeDto(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      isWalker: json['isWalker'] as bool,
      walkerStatus: json['walkerStatus'] as String?,
      businesses: raw
          .cast<Map<String, dynamic>>()
          .map(BusinessSummaryDto.fromJson)
          .toList(),
    );
  }

  Me toEntity() => Me(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        isWalker: isWalker,
        walkerStatus: walkerStatus,
        businesses: businesses.map((b) => b.toEntity()).toList(),
      );
}
