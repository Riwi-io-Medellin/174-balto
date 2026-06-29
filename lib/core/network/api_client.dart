import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient(TokenStorage tokenStorage) : dio = _build() {
    dio.interceptors.add(
      AuthInterceptor(tokenStorage: tokenStorage, dio: dio),
    );
  }

  final Dio dio;

  static Dio _build() {
    return Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status != 401 && status < 600,
      ),
    );
  }
}
