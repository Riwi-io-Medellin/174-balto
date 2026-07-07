import 'package:dio/dio.dart';

class UploadRemoteDataSource {
  UploadRemoteDataSource(this._dio);

  final Dio _dio;

  Future<String> uploadImage(String filePath) =>
      uploadFile(filePath, 'photo.jpg');

  Future<String> uploadFile(String filePath, String filename) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filename),
    });

    final response = await _dio.post<dynamic>(
      '/upload',
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    final status = response.statusCode ?? 0;
    final data = response.data;

    if (status == 200 && data is Map<String, dynamic>) {
      return data['url'] as String;
    }

    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['error'] is String) {
      throw UploadRemoteFailure(
        data['code'] as String,
        data['error'] as String,
      );
    }

    throw UploadRemoteFailure(
      'UPLOAD_FAILED',
      'Unexpected response ($status).',
    );
  }
}

class UploadRemoteFailure implements Exception {
  UploadRemoteFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'UploadRemoteFailure($code): $message';
}
