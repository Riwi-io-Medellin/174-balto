import 'package:equatable/equatable.dart';

class HomeProviderServiceItem extends Equatable {
  const HomeProviderServiceItem({
    required this.id,
    required this.serviceTypeId,
    required this.serviceTypeCode,
    required this.serviceTypeName,
    this.price,
    this.priceUnit = 'flat',
    this.description,
    this.isActive = true,
  });

  final String id;
  final String serviceTypeId;
  final String serviceTypeCode;
  final String serviceTypeName;
  final double? price;
  final String priceUnit; // flat | hourly | per_visit
  final String? description;
  final bool isActive;

  String get priceLabel {
    if (price == null) return 'Ask for price';
    final amount = '\$${price!.toStringAsFixed(0)}';
    return switch (priceUnit) {
      'hourly' => '$amount/hr',
      'per_visit' => '$amount/visit',
      _ => amount,
    };
  }

  @override
  List<Object?> get props => [
        id,
        serviceTypeId,
        serviceTypeCode,
        serviceTypeName,
        price,
        priceUnit,
        description,
        isActive,
      ];
}
