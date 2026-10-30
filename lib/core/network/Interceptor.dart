import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:thewhsherbiker/api/api_path.dart';
import 'package:thewhsherbiker/api/api_service.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/app.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';

class AuthInterceptor extends Interceptor {
  /// Shared across requests so concurrent 403s trigger a single refresh.
  static Future<String?>? _refreshing;
  static const String _retriedKey = 'authRetried';

  final Dio dio;
  AuthInterceptor({required this.dio});

  bool _requiresAuth(RequestOptions options) =>
      options.extra['requiresAuth'] == true &&
      options.path != ApiPaths.refreshTokens;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_requiresAuth(options)) return handler.next(options);

    await AppShared.getToken();
    if (AppShared.token.isNotEmpty &&
        AppShared.isTokenExpired(AppShared.token)) {
      try {
        await _refresh();
      } catch (_) {
        // Offline: send with the old token; a 403 will retry the refresh.
      }
    }
    if (AppShared.token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${AppShared.token}';
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    final RequestOptions options = response.requestOptions;
    // The backend answers 403 (not 401) for missing/expired credentials.
    if (response.statusCode != ApiService.unAuthorizedCode ||
        !_requiresAuth(options) ||
        options.extra[_retriedKey] == true) {
      return handler.next(response);
    }

    final String? newRefreshToken;
    try {
      newRefreshToken = await _refresh();
    } catch (_) {
      // Network failure while refreshing: keep the session, surface the 403.
      return handler.next(response);
    }
    if (newRefreshToken == null) {
      _goToLogin();
      return handler.next(response);
    }

    try {
      options.extra[_retriedKey] = true;
      options.headers['Authorization'] = 'Bearer ${AppShared.token}';
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.reject(e);
    }
  }

  Future<String?> _refresh() async {
    _refreshing ??=
        ApiService.refreshToken().whenComplete(() => _refreshing = null);
    return _refreshing;
  }

  void _goToLogin() {
    AppShared.setToken('');
    AppShared.setRefreshToken('');
    navigatorKeyAlice.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (BuildContext context) => LogInScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
