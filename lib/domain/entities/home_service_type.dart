import 'package:equatable/equatable.dart';

class HomeServiceType extends Equatable {
  const HomeServiceType({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  final String id;
  final String code;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [id, code, name, description];
}
