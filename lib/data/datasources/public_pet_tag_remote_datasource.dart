import 'package:dio/dio.dart';

import '../../domain/repositories/public_pet_tag_repository.dart';
import '../models/public_pet_tag_dto.dart';

class PublicPetTagRemoteDataSource {
  PublicPetTagRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PublicPetTagDto> getPublicInfo(String petId) async {
    final response = await _dio.get<dynamic>('/pet-tag/$petId');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return PublicPetTagDto.fromJson(data);
    }

    if (status == 404) {
      throw PublicPetTagFailure(
        'PET_NOT_FOUND',
        'This tag is not linked to a pet.',
      );
    }

    throw PublicPetTagFailure(
      'PET_TAG_FETCH_FAILED',
      'Unexpected response ($status).',
    );
  }

  Future<void> shareLocation({
    required String petId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.post<dynamic>(
      '/pet-tag/$petId/location',
      data: {'latitude': latitude, 'longitude': longitude},
    );
    final status = response.statusCode ?? 0;
    if (status == 204) return;

    if (status == 404) {
      throw PublicPetTagFailure(
        'PET_NOT_FOUND',
        'This tag is not linked to a pet.',
      );
    }

    throw PublicPetTagFailure(
      'SHARE_LOCATION_FAILED',
      'Unexpected response ($status).',
    );
  }
}
