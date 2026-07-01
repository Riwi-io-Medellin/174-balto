abstract class UploadRepository {
  Future<String> uploadImage(String filePath);
  Future<String> uploadFile(String filePath, String filename);
}

class UploadFailure implements Exception {
  UploadFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'UploadFailure($code): $message';
}
