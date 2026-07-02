import 'package:dio/dio.dart';

import '../../domain/repositories/home_favorite_provider_repository.dart';

class HomeFavoriteProviderRemoteDataSource {
  HomeFavoriteProviderRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<String>> getMyFavoriteProviderIds() async {
    final response = await _dio.get<dynamic>('/home-services/favorites');
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is List) {
      return data
          .map((e) => (e as Map<String, dynamic>)['providerId'] as String)
          .toList();
    }
    _throwFailure(status, data, 'FETCH_FAILED');
  }

  Future<void> addFavorite(String providerId) async {
    final response = await _dio
        .post<dynamic>('/home-services/favorites/$providerId');
    final status = response.statusCode ?? 0;
    if (status == 200 || status == 201) return;
    _throwFailure(status, response.data, 'ADD_FAILED');
  }

  Future<void> removeFavorite(String providerId) async {
    final response = await _dio
        .delete<dynamic>('/home-services/favorites/$providerId');
    final status = response.statusCode ?? 0;
    if (status == 204 || status == 200) return;
    _throwFailure(status, response.data, 'REMOVE_FAILED');
  }

  Never _throwFailure(int status, dynamic data, String fallbackCode) {
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw HomeFavoriteProviderFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }
    throw HomeFavoriteProviderFailure(
      fallbackCode,
      'Unexpected response ($status).',
    );
  }
}
