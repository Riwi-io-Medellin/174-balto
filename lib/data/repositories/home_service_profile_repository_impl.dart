import 'package:dio/dio.dart';

import '../../domain/entities/home_service_provider_profile.dart';
import '../../domain/repositories/home_service_profile_repository.dart';
import '../datasources/home_service_profile_remote_datasource.dart';

class HomeServiceProfileRepositoryImpl implements HomeServiceProfileRepository {
  HomeServiceProfileRepositoryImpl(this._remote);

  final HomeServiceProfileRemoteDataSource _remote;

  @override
  Future<HomeServiceProviderProfile?> getMyProfile() async {
    try {
      final dto = await _remote.getMe();
      return dto?.toEntity();
    } on HomeServiceProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceProfileFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<HomeServiceProviderProfile> becomeProvider() async {
    try {
      final dto = await _remote.becomeProvider();
      return dto.toEntity();
    } on HomeServiceProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceProfileFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<HomeServiceProviderProfile> apply({
    required String documentImagePath,
    required String baseLocation,
    required String experience,
    String? description,
  }) async {
    try {
      final dto = await _remote.apply(
        filePath: documentImagePath,
        baseLocation: baseLocation,
        experience: experience,
        description: description,
      );
      return dto.toEntity();
    } on HomeServiceProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceProfileFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<HomeServiceProviderProfile> updateMyProfile({
    String? bio,
    int? yearsOfExperience,
    bool? isAcceptingBookings,
    int? maxConcurrentBookings,
    String? baseLocation,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final dto = await _remote.updateMyProfile(
        bio: bio,
        yearsOfExperience: yearsOfExperience,
        isAcceptingBookings: isAcceptingBookings,
        maxConcurrentBookings: maxConcurrentBookings,
        baseLocation: baseLocation,
        latitude: latitude,
        longitude: longitude,
      );
      return dto.toEntity();
    } on HomeServiceProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw HomeServiceProfileFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
