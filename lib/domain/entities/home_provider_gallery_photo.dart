import 'package:equatable/equatable.dart';

class HomeProviderGalleryPhoto extends Equatable {
  const HomeProviderGalleryPhoto({required this.id, required this.photoUrl});

  final String id;
  final String photoUrl;

  @override
  List<Object?> get props => [id, photoUrl];
}
