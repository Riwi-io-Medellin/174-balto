import 'package:equatable/equatable.dart';

class WalkMedia extends Equatable {
  const WalkMedia({
    required this.id,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  final String id;
  final String url;
  final String type; // 'photo' | 'video'
  final DateTime uploadedAt;

  bool get isVideo => type == 'video';

  @override
  List<Object?> get props => [id, url, type, uploadedAt];
}
