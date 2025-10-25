import 'package:dio/dio.dart';
// Import ordenado alfabéticamente
import 'package:smart_task_manager/core/network/network_exceptions.dart';

class DioClient {
  // Constructor primero
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_createLoggingInterceptor());
  }

  // Variable después del constructor
  late final Dio _dio;

  InterceptorsWrapper _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // ignore: avoid_print
        print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // ignore: avoid_print
        // Print status and data in two prints to avoid long single-line issues.
        // ignore: avoid_print
        print('✅ RESPONSE[${response.statusCode}] =>');
        // ignore: avoid_print
        print('DATA: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        // ignore: avoid_print
        // ignore: avoid_print
        print('❌ ERROR[${error.response?.statusCode}] =>');
        // ignore: avoid_print
        print('MESSAGE: ${error.message}');
        return handler.next(error);
      },
    );
  }

  /// Runs [action] with a simple retry policy for transient errors.
  /// Retries up to [maxRetries] times with exponential backoff (in ms).
  Future<T> _withRetry<T>(
    Future<T> Function() action, {
    int maxRetries = 2,
    int backoffMillis = 200,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } on DioException catch (e) {
        attempt++;
        // Don't retry on client errors (4xx) or if we've exhausted retries.
        final status = e.response?.statusCode;
        final isClientError = status != null && status >= 400 && status < 500;
        final shouldRetry = !isClientError && attempt <= maxRetries;
        if (!shouldRetry) {
          throw NetworkException.fromDioError(e);
        }

        // Backoff before next retry
        final delay = backoffMillis * (1 << (attempt - 1));
        // ignore: avoid_print
        print('⏳ Retry attempt $attempt after ${delay}ms due to ${e.message}');
        await Future<void>.delayed(Duration(milliseconds: delay));
        // loop and retry
      }
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _withRetry<Response<dynamic>>(() => _dio.get<dynamic>(
            path,
            queryParameters: queryParams,
          ));
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _withRetry<Response<dynamic>>(
        () => _dio.post<dynamic>(path, data: data),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await _withRetry<Response<dynamic>>(() => _dio.delete<dynamic>(path));
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Response<dynamic>> put(String path, {required Map<String, dynamic> data}) async {
    try {
      return await _withRetry<Response<dynamic>>(() => _dio.put<dynamic>(path, data: data));
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Response<dynamic>> patch(String path, {required Map<String, dynamic> data}) async {
    try {
      return await _withRetry<Response<dynamic>>(() => _dio.patch<dynamic>(path, data: data));
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}
