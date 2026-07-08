import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _rememberKey = 'auth_remember_me';
  static const _coachHistoryKey = 'coach_chat_history';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> saveRememberMe(bool value) =>
      _storage.write(key: _rememberKey, value: value.toString());

  Future<bool?> readRememberMe() async {
    final v = await _storage.read(key: _rememberKey);
    if (v == null) return null;
    return v == 'true';
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _rememberKey);
    await _storage.delete(key: _coachHistoryKey);
  }
}
