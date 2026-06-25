abstract class UploadRepository {
  Future<String> uploadImage(String filePath);
}

class UploadFailure implements Exception {
  UploadFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'UploadFailure($code): $message';
}
