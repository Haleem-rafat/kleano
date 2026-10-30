import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewhsherbiker/api/api_path.dart';

import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/app.dart';
import 'package:thewhsherbiker/modules/Auth/data/model/auth_model.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';

class AuthInterceptor extends Interceptor {
  Future? refreshFuture;
  final Dio dio;
  AuthInterceptor({required this.dio});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print("Request [${options.method}] => PATH: ${options.path}");

    if (options.extra["requiresAuth"] == false) {
      return handler.next(options);
    }

    await AppShared.getToken();

    if (AppShared.token.isEmpty) {
      // No token, treat as unauthenticated
      navigatorKeyAlice.currentState?.pushReplacement(
        MaterialPageRoute(
            builder: (context) => LogInScreen(
                )),
      );
      return handler.next(options);
    }

    if (AppShared.isTokenExpired(AppShared.token)) {
      var refreshToken = await AppShared.getRefreshToken();
      if (refreshToken == null ||
          refreshToken.isEmpty ||
          AppShared.isTokenExpired(refreshToken)) {
        // Both tokens are expired or missing, force login
        navigatorKeyAlice.currentState?.pushReplacement(
          MaterialPageRoute(
              builder: (context) => LogInScreen(
                  )),
        );
        return handler.next(options);
      }
      // Try to refresh
      if (refreshFuture == null) {
        refreshFuture = _handleRefreshtoken(refreshToken);
        try {
          await refreshFuture;
        } finally {
          refreshFuture = null;
        }
      } else {
        await refreshFuture;
      }
      await AppShared.getToken();
      options.headers["Authorization"] = "Bearer ${AppShared.token}";
    } else {
      // Token is valid
      options.headers["Authorization"] = "Bearer ${AppShared.token}";
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        "Response [${response.statusCode}] => PATH: ${response.requestOptions.path}");
    super.onResponse(response, handler);
  }

  @override
  void onError(err, ErrorInterceptorHandler handler) async {
    print(
        "Error [${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");

    super.onError(err, handler);
  }

  Future<void> _handleRefreshtoken(String refreshToken) async {
    var response = await dio.post(
      ApiPaths.refreshTokens,
      options: Options(extra: {
        "requiresAuth": false
      }, headers: {
        "Authorization": 'Bearer $refreshToken',
        "x-api-version": "1"
      }),
    );

    final authResponse = AuthModel.fromJson(response.data);
    final prefs = await SharedPreferences.getInstance();
    
    await AppShared.setToken(authResponse.accessToken!);
    await AppShared.setRefreshToken(authResponse.refreshToken!);
  }
}
