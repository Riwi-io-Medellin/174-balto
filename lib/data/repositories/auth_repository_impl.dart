import 'package:dio/dio.dart';

import '../../core/storage/token_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthTokens> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String idNumber,
    required String idType,
    required String phone,
  }) async {
    try {
      final dto = await _remote.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        idNumber: idNumber,
        idType: idType,
        phone: phone,
      );
      await _tokenStorage.save(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );
      await _tokenStorage.saveRememberMe(true);
      return dto.toEntity();
    } on DioException catch (e) {
      throw AuthFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final dto = await _remote.login(email: email, password: password);
      await _tokenStorage.save(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );
      await _tokenStorage.saveRememberMe(rememberMe);
      return dto.toEntity();
    } on DioException catch (e) {
      throw AuthFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<AuthTokens> refresh({required String refreshToken}) async {
    try {
      final dto = await _remote.refresh(refreshToken: refreshToken);
      await _tokenStorage.save(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );
      return dto.toEntity();
    } on DioException catch (e) {
      throw AuthFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _remote.logout(refreshToken: refreshToken);
      } catch (_) {}
    }
    await _tokenStorage.clear();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on AuthFailure {
      rethrow;
    } on DioException catch (e) {
      throw AuthFailure(
        'NETWORK_ERROR',
        e.message ?? 'Could not reach the server.',
      );
    }
  }

  @override
  Future<AuthTokens?> restoreSession() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (accessToken == null || refreshToken == null) return null;
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }
}
