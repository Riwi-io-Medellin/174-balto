import '../entities/public_pet_tag_info.dart';

abstract class PublicPetTagRepository {
  Future<PublicPetTagInfo> getPublicInfo(String petId);

  Future<void> shareLocation({
    required String petId,
    required double latitude,
    required double longitude,
  });
}

class PublicPetTagFailure implements Exception {
  PublicPetTagFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PublicPetTagFailure($code): $message';
}
