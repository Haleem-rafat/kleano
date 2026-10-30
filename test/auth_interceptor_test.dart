import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/api/Interceptor.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/shared.dart';

String jwt(Duration expiresIn) {
  String b64(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final int exp =
      DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000;
  return '${b64(<String, dynamic>{'alg': 'HS256'})}.${b64(<String, dynamic>{'exp': exp})}.sig';
}

/// Answers requests from a handler and records what was sent.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    });

Dio buildDio(FakeAdapter adapter) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(AuthInterceptor(dio: dio));
  return dio;
}

Options auth() => Options(extra: <String, dynamic>{'requiresAuth': true});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppShared.token = '';
    AppShared.refreshToken = '';
  });

  test('guest (no token) requests go out anonymously instead of redirecting',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final FakeAdapter adapter =
        FakeAdapter((_) => json(200, <String, dynamic>{'success': true}));

    final Response<dynamic> res =
        await buildDio(adapter).get('/washing-services/guest/all', options: auth());

    expect(res.statusCode, 200);
    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('403 refreshes once and retries with the new token', () async {
    final String oldToken = jwt(const Duration(hours: 1));
    final String newToken = jwt(const Duration(hours: 2));
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppShared.sharedPreferenceTokenKey: oldToken,
      AppShared.sharedPreferencesRefreshTokenKey: jwt(const Duration(days: 7)),
    });

    final FakeAdapter adapter = FakeAdapter((RequestOptions o) {
      if (o.path == ApiPaths.refreshTokens) {
        return json(201, <String, dynamic>{
          'success': true,
          'data': <String, dynamic>{
            'access_token': newToken,
            'refresh_token': jwt(const Duration(days: 8)),
          },
        });
      }
      final bool fresh = o.headers['Authorization'] == 'Bearer $newToken';
      return fresh
          ? json(200, <String, dynamic>{'success': true})
          : json(403, <String, dynamic>{'success': false});
    });

    final Response<dynamic> res =
        await buildDio(adapter).get('/orders/user/all', options: auth());

    expect(res.statusCode, 200);
    final List<String> paths =
        adapter.requests.map((RequestOptions o) => o.path).toList();
    expect(paths, <String>['/orders/user/all', ApiPaths.refreshTokens, '/orders/user/all']);
    // Backend contract: refresh token goes in the JSON body.
    expect(adapter.requests[1].data, containsPair('refresh_token', isA<String>()));
  });

  test('concurrent 403s share a single refresh call', () async {
    final String newToken = jwt(const Duration(hours: 2));
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppShared.sharedPreferenceTokenKey: jwt(const Duration(hours: 1)),
      AppShared.sharedPreferencesRefreshTokenKey: jwt(const Duration(days: 7)),
    });
    final FakeAdapter adapter = FakeAdapter((RequestOptions o) {
      if (o.path == ApiPaths.refreshTokens) {
        return json(201, <String, dynamic>{
          'data': <String, dynamic>{
            'access_token': newToken,
            'refresh_token': jwt(const Duration(days: 8)),
          },
        });
      }
      return o.headers['Authorization'] == 'Bearer $newToken'
          ? json(200, <String, dynamic>{})
          : json(403, <String, dynamic>{});
    });
    final Dio dio = buildDio(adapter);

    await Future.wait(<Future<Response<dynamic>>>[
      dio.get('/a', options: auth()),
      dio.get('/b', options: auth()),
      dio.get('/c', options: auth()),
    ]);

    expect(
      adapter.requests.where((RequestOptions o) => o.path == ApiPaths.refreshTokens),
      hasLength(1),
    );
  });

  test('rejected refresh does not loop and surfaces the 403', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppShared.sharedPreferenceTokenKey: jwt(const Duration(hours: 1)),
      AppShared.sharedPreferencesRefreshTokenKey: jwt(const Duration(days: 7)),
    });
    final FakeAdapter adapter =
        FakeAdapter((_) => json(403, <String, dynamic>{'success': false}));

    await expectLater(
      buildDio(adapter).get('/orders/user/all', options: auth()),
      throwsA(isA<DioException>().having(
          (DioException e) => e.response?.statusCode, 'status', 403)),
    );
    // original + one refresh attempt, no retry storm
    expect(adapter.requests, hasLength(2));
  });
}
