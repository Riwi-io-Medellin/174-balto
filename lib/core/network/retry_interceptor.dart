import 'package:dio/dio.dart';

/// Retries a request exactly once, after a short delay, when it fails with a
/// transient connection/timeout error (not a business 4xx/5xx response) —
/// covers one-off hiccups against the backend without masking real failures.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;

  static const _transientTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final opts = err.requestOptions;
    final alreadyRetried = opts.extra['_retriedTransient'] == true;

    if (alreadyRetried || !_transientTypes.contains(err.type)) {
      handler.next(err);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    opts.extra['_retriedTransient'] = true;

    try {
      final response = await _dio.fetch<dynamic>(opts);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }
}
