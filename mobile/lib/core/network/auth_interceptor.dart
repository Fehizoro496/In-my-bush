import 'package:dio/dio.dart';
import '../utils/json.dart';
import 'endpoints/endpoints.dart';
import 'token_storage.dart';

/// One rotation shared by concurrent 401s; every protected request is replayed at most once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required Dio dio, required TokenStorage storage, this.onSessionExpired, Dio? refreshDio})
      : _dio = dio, _storage = storage,
        _refreshDio = refreshDio ?? Dio(BaseOptions(
          baseUrl: dio.options.baseUrl, connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout));
  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _storage;
  final void Function()? onSessionExpired;
  Future<String?>? _refreshing;
  bool _expired = false;
  static const _retriedKey = 'imb.retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.path.contains(AuthEndpoints.prefix)) {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        _expired = false;
      }
    }
    handler.next(options);
  }

  Future<void> _expire() async {
    await _storage.clear();
    if (!_expired) {
      _expired = true;
      onSessionExpired?.call();
    }
  }

  Future<String?> _rotate() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh == null) { await _expire(); return null; }
    try {
      final response = await _refreshDio.post<dynamic>(AuthEndpoints.refresh, data: {'refreshToken': refresh});
      final body = readMap(response.data);
      final access = readStringOrNull(body['accessToken']);
      final next = readStringOrNull(body['refreshToken']);
      if (access == null || access.isEmpty || next == null || next.isEmpty) {
        await _expire(); return null;
      }
      // A logout or a new login must win over an in-flight rotation.
      if (await _storage.readRefreshToken() != refresh) return null;
      await _storage.save(accessToken: access, refreshToken: next);
      return access;
    } catch (_) {
      await _expire();
      return null;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 || options.path.contains(AuthEndpoints.prefix)) {
      handler.next(err); return;
    }
    if (options.extra[_retriedKey] == true) {
      await _expire(); handler.next(err); return;
    }
    final current = await _storage.readAccessToken();
    String? access;
    if (current != null && options.headers['Authorization'] != 'Bearer $current') {
      access = current;
    } else {
      final pending = _refreshing ??= _rotate();
      try { access = await pending; }
      finally { if (identical(_refreshing, pending)) _refreshing = null; }
    }
    if (access == null) { handler.next(err); return; }
    options.headers['Authorization'] = 'Bearer $access';
    options.extra[_retriedKey] = true;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}

