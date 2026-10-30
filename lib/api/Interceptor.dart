import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/app.dart';
import 'package:thewasher/models/auth_model.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';

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
        MaterialPageRoute(builder: (context) => ChooseRegisterView()),
      );
      return handler.next(options);
    }

    if (AppShared.isTokenExpired(AppShared.token)) {
      var refreshToken = await AppShared.getRefreshToken();
      if (refreshToken == null ||
          refreshToken.isEmpty ||
          AppShared.isTokenExpired(refreshToken)) {
        navigatorKeyAlice.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => ChooseRegisterView()),
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

    // Handle 403 Unauthorized - retry after token refresh
    if (err.response?.statusCode == 403) {
      final requestOptions = err.requestOptions;

      // Skip retry for refresh token endpoint to avoid infinite loop
      if (requestOptions.path == ApiPaths.refreshTokens) {
        return super.onError(err, handler);
      }

      // Skip retry if auth is not required
      if (requestOptions.extra["requiresAuth"] == false) {
        return super.onError(err, handler);
      }

      // Refresh token
      await AppShared.getRefreshToken();
      if (AppShared.refreshToken.isNotEmpty &&
          !AppShared.isTokenExpired(AppShared.refreshToken)) {
        try {
          // Use existing refresh mechanism to avoid concurrent refreshes
          if (refreshFuture == null) {
            refreshFuture = _handleRefreshtoken(AppShared.refreshToken);
            try {
              await refreshFuture;
            } finally {
              refreshFuture = null;
            }
          } else {
            await refreshFuture;
          }

          // Retry the original request with new token
          final retryResponse = await _retryRequest(requestOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          // If refresh fails, proceed with original error
          print("Token refresh failed: $e");
        }
      } else {
        // Refresh token invalid, redirect to login
        navigatorKeyAlice.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => ChooseRegisterView()),
        );
      }
    }

    super.onError(err, handler);
  }

  /// Retries a request with the same method, path, params, and body
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    await AppShared.getToken();

    // Update authorization header with new token
    requestOptions.headers["Authorization"] = "Bearer ${AppShared.token}";

    // Retry based on HTTP method
    switch (requestOptions.method.toUpperCase()) {
      case 'GET':
        return await dio.get(
          requestOptions.path,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            extra: requestOptions.extra,
            validateStatus: requestOptions.validateStatus,
          ),
        );
      case 'POST':
        return await dio.post(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            extra: requestOptions.extra,
            contentType: requestOptions.contentType,
            validateStatus: requestOptions.validateStatus,
          ),
        );
      case 'PUT':
        return await dio.put(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            extra: requestOptions.extra,
            contentType: requestOptions.contentType,
            validateStatus: requestOptions.validateStatus,
          ),
        );
      case 'PATCH':
        return await dio.patch(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            extra: requestOptions.extra,
            contentType: requestOptions.contentType,
            validateStatus: requestOptions.validateStatus,
          ),
        );
      case 'DELETE':
        return await dio.delete(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            extra: requestOptions.extra,
            contentType: requestOptions.contentType,
            validateStatus: requestOptions.validateStatus,
          ),
        );
      default:
        throw Exception('Unsupported HTTP method: ${requestOptions.method}');
    }
  }

  Future<void> _handleRefreshtoken(String refreshToken) async {
    var response = await dio.post(
      ApiPaths.refreshTokens,
      data: {"refresh_token": refreshToken},
      options: Options(extra: {"requiresAuth": false}),
    );

    final authResponse = AuthModel.fromJson(response.data);
    AppShared.setToken(authResponse.data!.accessToken!);
    AppShared.setRefreshToken(authResponse.data!.refreshToken!);
  }
}
