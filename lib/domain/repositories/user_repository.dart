import '../entities/user.dart';

abstract class UserRepository {
  Future<User> getById(String id);
  Future<User> update({
    required String id,
    required String firstName,
    required String lastName,
    required String idNumber,
    required String idType,
    required String phone,
    String? phoneExtra,
    String? location,
    String? address,
    String? photoUrl,
  });
}

class UserFailure implements Exception {
  UserFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'UserFailure($code): $message';
}
