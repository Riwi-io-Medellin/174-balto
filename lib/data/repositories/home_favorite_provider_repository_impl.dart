import 'package:dio/dio.dart';

import '../../domain/repositories/home_favorite_provider_repository.dart';
import '../datasources/home_favorite_provider_remote_datasource.dart';

class HomeFavoriteProviderRepositoryImpl
    implements HomeFavoriteProviderRepository {
  HomeFavoriteProviderRepositoryImpl(this._remote);

  final HomeFavoriteProviderRemoteDataSource _remote;

  @override
  Future<List<String>> getMyFavoriteProviderIds() async {
    try {
      return await _remote.getMyFavoriteProviderIds();
    } on HomeFavoriteProviderFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeFavoriteProviderFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> addFavorite(String providerId) async {
    try {
      await _remote.addFavorite(providerId);
    } on HomeFavoriteProviderFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeFavoriteProviderFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> removeFavorite(String providerId) async {
    try {
      await _remote.removeFavorite(providerId);
    } on HomeFavoriteProviderFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeFavoriteProviderFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
