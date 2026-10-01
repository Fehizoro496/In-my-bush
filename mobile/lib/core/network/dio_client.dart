import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../utils/json.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Configured Dio instance: base URL from `--dart-define=API_URL`,
/// JSON, auth interceptor (JWT + refresh).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      headers: const {'Accept': 'application/json, application/problem+json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(dio: dio, storage: ref.watch(tokenStorageProvider)));
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: false, logPrint: (Object line) => debugPrint(line.toString())));
  }
  return dio;
});

/// Thin wrapper that converts [DioException] into [ApiException] and
/// unwraps JSON bodies.
class ApiClient {
  const ApiClient(this.dio);

  final Dio dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => dio.get<dynamic>(path, queryParameters: _clean(query)));

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query}) =>
      _send(() => dio.post<dynamic>(path, data: body, queryParameters: _clean(query)));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() => dio.patch<dynamic>(path, data: body));

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() => dio.put<dynamic>(path, data: body));

  Future<dynamic> delete(String path) => _send(() => dio.delete<dynamic>(path));

  Future<JsonMap> getMap(String path, {Map<String, dynamic>? query}) async =>
      readMap(await get(path, query: query));

  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query}) async {
    final data = await get(path, query: query);
    if (data is List) return data;
    // Some endpoints are paginated: { items: [...] }
    final items = readMap(data)['items'];
    return items is List ? items : const [];
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) return null;
    final copy = Map<String, dynamic>.of(query)
      ..removeWhere((key, value) => value == null || (value is String && value.isEmpty));
    return copy;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)));
