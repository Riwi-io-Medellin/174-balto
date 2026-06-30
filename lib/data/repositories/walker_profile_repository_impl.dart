import 'package:dio/dio.dart';

import '../../domain/entities/walker_profile.dart';
import '../../domain/repositories/walker_profile_repository.dart';
import '../datasources/walker_profile_remote_datasource.dart';

class WalkerProfileRepositoryImpl implements WalkerProfileRepository {
  WalkerProfileRepositoryImpl(this._remote);

  final WalkerProfileRemoteDataSource _remote;

  @override
  Future<WalkerProfile?> getMyProfile() async {
    try {
      final dto = await _remote.getMe();
      return dto?.toEntity();
    } on WalkerProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkerProfileFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<WalkerProfile> apply({
    required String documentImagePath,
    required String workLocation,
    required String experience,
    String? description,
  }) async {
    try {
      final dto = await _remote.apply(
        filePath: documentImagePath,
        workLocation: workLocation,
        experience: experience,
        description: description,
      );
      return dto.toEntity();
    } on WalkerProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkerProfileFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<WalkerProfile> updateMyProfile({
    String? bio,
    double? hourlyRate,
    double? serviceRadiusKm,
    int? yearsOfExperience,
    bool? isAcceptingBookings,
    int? maxDogs,
    double? workLatitude,
    double? workLongitude,
  }) async {
    try {
      final dto = await _remote.updateMyProfile(
        bio: bio,
        hourlyRate: hourlyRate,
        serviceRadiusKm: serviceRadiusKm,
        yearsOfExperience: yearsOfExperience,
        isAcceptingBookings: isAcceptingBookings,
        maxDogs: maxDogs,
        workLatitude: workLatitude,
        workLongitude: workLongitude,
      );
      return dto.toEntity();
    } on WalkerProfileFailure {
      rethrow;
    } on DioException catch (e) {
      throw WalkerProfileFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
