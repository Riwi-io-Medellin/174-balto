import 'package:equatable/equatable.dart';

class HomeProviderCertification extends Equatable {
  const HomeProviderCertification({
    required this.id,
    required this.title,
    this.issuingOrganization,
    this.credentialNumber,
    this.issuedDate,
    this.expiryDate,
    this.documentUrl,
  });

  final String id;
  final String title;
  final String? issuingOrganization;
  final String? credentialNumber;
  final String? issuedDate;
  final String? expiryDate;
  final String? documentUrl;

  @override
  List<Object?> get props => [
        id,
        title,
        issuingOrganization,
        credentialNumber,
        issuedDate,
        expiryDate,
        documentUrl,
      ];
}
