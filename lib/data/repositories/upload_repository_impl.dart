import 'package:dio/dio.dart';

import '../../domain/repositories/upload_repository.dart';
import '../datasources/upload_remote_datasource.dart';

class UploadRepositoryImpl implements UploadRepository {
  UploadRepositoryImpl(this._remote);

  final UploadRemoteDataSource _remote;

  @override
  Future<String> uploadImage(String filePath) async {
    try {
      return await _remote.uploadImage(filePath);
    } on UploadRemoteFailure {
      rethrow;
    } on DioException catch (e) {
      throw UploadFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }
}
