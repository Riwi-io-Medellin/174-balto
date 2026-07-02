import 'package:equatable/equatable.dart';

class HomeProviderDocument extends Equatable {
  const HomeProviderDocument({
    required this.id,
    required this.documentType,
    required this.fileUrl,
  });

  final String id;
  final String documentType;
  final String fileUrl;

  @override
  List<Object?> get props => [id, documentType, fileUrl];
}
