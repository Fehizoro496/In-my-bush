import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_my_bush/core/network/auth_interceptor.dart';
import 'package:in_my_bush/core/network/token_storage.dart';

class MemoryTokens extends TokenStorage {
  String? access = 'old';
  String? refresh = 'refresh';
  @override Future<String?> readAccessToken() async => access;
  @override Future<String?> readRefreshToken() async => refresh;
  @override Future<void> save({required String accessToken, String? refreshToken}) async {
    access = accessToken; refresh = refreshToken;
  }
  @override Future<void> clear() async { access = null; refresh = null; }
}
class Adapter implements HttpClientAdapter {
  Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) => respond(options);
  @override void close({bool force = false}) {}
}
ResponseBody body(int status, [Object data = const {}]) => ResponseBody.fromString(jsonEncode(data), status,
    headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});

void main() {
  late MemoryTokens tokens;
  late Dio dio;
  late Dio refreshDio;
  late int rotations;
  late int expired;
  setUp(() {
    tokens = MemoryTokens(); rotations = 0; expired = 0;
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
    refreshDio.httpClientAdapter = Adapter((_) async {
      rotations++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return body(200, {'accessToken': 'new', 'refreshToken': 'rotated'});
    });
    dio.interceptors.add(AuthInterceptor(dio: dio, storage: tokens, refreshDio: refreshDio,
        onSessionExpired: () => expired++));
  });
  tearDown(() { dio.close(); refreshDio.close(); });

  test('concurrent 401s share a rotation and replay with the new token', () async {
    dio.httpClientAdapter = Adapter((request) async => body(request.headers['Authorization'] == 'Bearer new' ? 200 : 401));
    final responses = await Future.wait([dio.get<dynamic>('/me'), dio.get<dynamic>('/me/orders')]);
    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(rotations, 1); expect(tokens.refresh, 'rotated'); expect(expired, 0);
  });
  test('login errors never trigger refresh', () async {
    dio.httpClientAdapter = Adapter((request) async { expect(request.headers['Authorization'], isNull); return body(401); });
    await expectLater(dio.post<dynamic>('/auth/login'), throwsA(isA<DioException>()));
    expect(rotations, 0); expect(expired, 0);
  });
  test('a rejected refresh clears storage and expires the session', () async {
    dio.httpClientAdapter = Adapter((_) async => body(401));
    refreshDio.httpClientAdapter = Adapter((_) async { rotations++; return body(401); });
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(rotations, 1); expect(tokens.access, isNull); expect(tokens.refresh, isNull); expect(expired, 1);
  });
  test('a second 401 expires the session without a second refresh', () async {
    var requests = 0;
    dio.httpClientAdapter = Adapter((_) async { requests++; return body(401); });
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(requests, 2); expect(rotations, 1); expect(expired, 1);
  });
  test('a server error on replay does not clear a valid session', () async {
    dio.httpClientAdapter = Adapter((request) async => body(request.headers['Authorization'] == 'Bearer new' ? 500 : 401));
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(tokens.access, 'new'); expect(expired, 0);
  });
  test('logout wins over an in-flight refresh', () async {
    dio.httpClientAdapter = Adapter((_) async => body(401));
    refreshDio.httpClientAdapter = Adapter((_) async {
      await tokens.clear(); return body(200, {'accessToken':'new','refreshToken':'rotated'});
    });
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(tokens.access, isNull);
  });
}
