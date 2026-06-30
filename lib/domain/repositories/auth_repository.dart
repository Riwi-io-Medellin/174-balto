import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<AuthTokens> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String idNumber,
    required String idType,
    required String phone,
  });

  Future<AuthTokens> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<AuthTokens> refresh({required String refreshToken});

  Future<void> logout();

  Future<AuthTokens?> restoreSession();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthFailure implements Exception {
  AuthFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AuthFailure($code): $message';
}
