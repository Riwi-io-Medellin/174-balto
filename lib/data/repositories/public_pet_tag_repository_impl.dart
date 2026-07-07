import 'package:dio/dio.dart';

import '../../domain/entities/public_pet_tag_info.dart';
import '../../domain/repositories/public_pet_tag_repository.dart';
import '../datasources/public_pet_tag_remote_datasource.dart';

class PublicPetTagRepositoryImpl implements PublicPetTagRepository {
  PublicPetTagRepositoryImpl(this._remote);

  final PublicPetTagRemoteDataSource _remote;

  @override
  Future<PublicPetTagInfo> getPublicInfo(String petId) async {
    try {
      final dto = await _remote.getPublicInfo(petId);
      return dto.toEntity();
    } on PublicPetTagFailure {
      rethrow;
    } on DioException catch (e) {
      throw PublicPetTagFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
