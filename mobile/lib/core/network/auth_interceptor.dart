import 'package:dio/dio.dart';

import '../utils/json.dart';
import 'endpoints/endpoints.dart';
import 'token_storage.dart';

/// Adds `Authorization: Bearer <access>` to every request and, on a 401,
/// refreshes the token pair once (`POST /auth/refresh`) then replays the
/// original request. Requests are queued while a refresh is running.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required Dio dio, required TokenStorage storage, this.onSessionExpired})
      : _dio = dio,
        _storage = storage;

  final Dio _dio;
  final TokenStorage _storage;

  /// Called when the refresh token is missing or rejected.
  final void Function()? onSessionExpired;

  static const _retriedKey = 'imb.retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers['Authorization'] == null) {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isAuthCall = options.path.contains(AuthEndpoints.prefix);
    if (err.response?.statusCode != 401 || isAuthCall || options.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) {
      onSessionExpired?.call();
      handler.next(err);
      return;
    }

    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
      ));
      final response = await refreshDio.post<dynamic>(
        AuthEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final body = readMap(response.data);
      final access = readStringOrNull(body['accessToken']);
      if (access == null) {
        await _storage.clear();
        onSessionExpired?.call();
        handler.next(err);
        return;
      }
      await _storage.save(
        accessToken: access,
        refreshToken: readStringOrNull(body['refreshToken']) ?? refreshToken,
      );

      options.headers['Authorization'] = 'Bearer $access';
      options.extra[_retriedKey] = true;
      final retried = await _dio.fetch<dynamic>(options);
      handler.resolve(retried);
    } on DioException catch (refreshError) {
      await _storage.clear();
      onSessionExpired?.call();
      handler.next(refreshError);
    }
  }
}
