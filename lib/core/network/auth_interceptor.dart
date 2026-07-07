import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor({required this.tokenStorage, required Dio dio})
    // ignore: prefer_initializing_formals
    : _dio = dio,
      _refreshDio = Dio(
        // separate instance — no auth interceptor, prevents refresh loop
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

  final TokenStorage tokenStorage;
  final Dio _dio;
  final Dio _refreshDio;

  // Shared across concurrent 401s so a token expiry doesn't trigger one
  // /auth/refresh call per in-flight request — everyone awaits the same
  // refresh instead of serializing N separate round trips through the queue.
  Future<String?>? _refreshFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final opts = err.requestOptions;

    if (opts.path.contains('/auth/refresh') || opts.extra['_retried'] == true) {
      await tokenStorage.clear();
      handler.next(err);
      return;
    }

    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      await tokenStorage.clear();
      handler.next(err);
      return;
    }

    final newAccessToken = await (_refreshFuture ??= _refreshAccessToken(
      refreshToken,
    ).whenComplete(() => _refreshFuture = null));

    if (newAccessToken != null) {
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      opts.extra['_retried'] = true;
      try {
        final retryResponse = await _dio.fetch<dynamic>(opts);
        handler.resolve(retryResponse);
        return;
      } catch (_) {}
    }

    await tokenStorage.clear();
    handler.next(err);
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final refreshResponse = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = refreshResponse.data;
      if (refreshResponse.statusCode == 200 && data != null) {
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;
        await tokenStorage.save(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return newAccessToken;
      }
    } catch (_) {}
    return null;
  }
}
