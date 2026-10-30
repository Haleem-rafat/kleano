import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/app.dart';
import 'package:thewasher/models/auth_model.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';

class AuthInterceptor extends Interceptor {
  /// Shared so concurrent requests/403s trigger a single refresh call.
  static Future<bool>? _refreshing;
  static const String _retriedKey = 'authRetried';

  final Dio dio;
  AuthInterceptor({required this.dio});

  bool _requiresAuth(RequestOptions options) =>
      options.extra['requiresAuth'] != false &&
      options.path != ApiPaths.refreshTokens;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_requiresAuth(options)) return handler.next(options);

    await AppShared.getToken();
    // Guests have no token: send the request anonymously instead of
    // redirecting, so guest browsing (services, plans, banners) keeps working.
    if (AppShared.token.isEmpty) return handler.next(options);

    if (AppShared.isTokenExpired(AppShared.token)) {
      final bool refreshed = await _refreshSafely();
      if (!refreshed) {
        _goToRegister();
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'Session expired',
          ),
        );
      }
    }
    options.headers['Authorization'] = 'Bearer ${AppShared.token}';
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final RequestOptions options = err.requestOptions;
    // The backend answers 403 (not 401) for missing/expired credentials.
    if (err.response?.statusCode != 403 ||
        !_requiresAuth(options) ||
        AppShared.token.isEmpty ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    if (!await _refreshSafely()) {
      _goToRegister();
      return handler.next(err);
    }

    try {
      options.extra[_retriedKey] = true;
      options.headers['Authorization'] = 'Bearer ${AppShared.token}';
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Returns false only when the backend rejects the refresh token. Network
  /// failures keep the session (the request just fails and can be retried).
  Future<bool> _refreshSafely() {
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _refresh() async {
    final String? refreshToken = await AppShared.getRefreshToken();
    if (refreshToken == null ||
        refreshToken.isEmpty ||
        AppShared.isTokenExpired(refreshToken)) {
      return false;
    }
    try {
      final Response<dynamic> response = await dio.post<dynamic>(
        ApiPaths.refreshTokens,
        data: <String, dynamic>{'refresh_token': refreshToken},
        options: Options(extra: <String, dynamic>{'requiresAuth': false}),
      );
      final AuthModel auth = AuthModel.fromJson(response.data);
      await AppShared.setToken(auth.data!.accessToken!);
      await AppShared.setRefreshToken(auth.data!.refreshToken!);
      return true;
    } on DioException catch (e) {
      final int? status = e.response?.statusCode;
      return !(status == 401 || status == 403 || status == 404);
    } catch (_) {
      return false;
    }
  }

  void _goToRegister() {
    AppShared.setToken('');
    AppShared.setRefreshToken('');
    navigatorKeyAlice.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(
          builder: (BuildContext context) => ChooseRegisterView()),
      (Route<dynamic> route) => false,
    );
  }
}
