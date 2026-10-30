import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:thewhsherbiker/api/api_path.dart';
import 'package:thewhsherbiker/api/app_config.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/network/Interceptor.dart';

class ApiService {
  static const String urlEncodedType = 'multipart/form-data';
  static const String jsonType = 'application/json';
  static const int unAuthorizedCode = 403;
  static const int internalServerErrorCode = 500;

  /// One shared client: connection pooling, a single refresh lock and one
  /// interceptor chain instead of a new Dio per request.
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.getAppBaseUrl(),
        // The backend can cold-start (Render), so allow a slow first response.
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        // Callers read 4xx bodies (validation / localized messages) themselves.
        validateStatus: (int? status) =>
            status != null && status < internalServerErrorCode,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (Object? object) => log(object.toString(), name: 'HTTP'),
        ),
      );
    }
    dio.interceptors.add(AuthInterceptor(dio: dio));
    return dio;
  }

  static Options _options(bool isAuth, {String? contentType}) => Options(
        extra: <String, dynamic>{'requiresAuth': isAuth},
        contentType: contentType,
      );

  static Future<Response<T>?> getApi<T>(String path,
      {bool isAuth = true}) async {
    return _dio.get<T>(path, options: _options(isAuth));
  }

  static Future<Response<T>?> postApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return _dio.post<T>(
      path,
      data: body,
      options: _options(isAuth, contentType: isJson ? jsonType : urlEncodedType),
    );
  }

  static Future<Response<T>?> deleteApi<T>(
    String path, {
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return _dio.delete<T>(
      path,
      options: _options(isAuth, contentType: isJson ? jsonType : urlEncodedType),
    );
  }

  static Future<Response<T>?> patchApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return _dio.patch<T>(
      path,
      data: body,
      options: _options(isAuth, contentType: isJson ? jsonType : urlEncodedType),
    );
  }

  static Future<Response<T>?> putApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return _dio.put<T>(
      path,
      data: body,
      options: _options(isAuth, contentType: isJson ? jsonType : urlEncodedType),
    );
  }

  static Future<Response<T>?> putMultiPartApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    List<String?>? filesName,
    List<File>? files,
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return _dio.put<T>(
      path,
      data: await _formData(body, files, filesName),
      options: _options(isAuth, contentType: urlEncodedType),
    );
  }

  static Future<Response<T>?> postMultiPartApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    List<String?>? filesName,
    List<File>? files,
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return _dio.post<T>(
      path,
      data: await _formData(body, files, filesName),
      options: _options(isAuth, contentType: urlEncodedType),
    );
  }

  static Future<Response<T>?> patchMultiPartApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    List<String?>? filesName,
    List<File>? files,
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return _dio.patch<T>(
      path,
      data: await _formData(body, files, filesName),
      options: _options(isAuth, contentType: urlEncodedType),
    );
  }

  static Future<FormData> _formData(Map<String, dynamic> body,
      List<File>? files, List<String?>? filesName) async {
    final FormData formData = FormData();
    body.forEach((String key, dynamic value) {
      if (value is List) {
        for (final dynamic e in value) {
          formData.fields.add(MapEntry<String, String>(key, e.toString()));
        }
      } else {
        formData.fields.add(MapEntry<String, String>(key, value.toString()));
      }
    });

    for (int i = 0; i < (files?.length ?? 0); i++) {
      final File file = files![i];
      final String fileName = file.path.split('/').last;
      final String field = filesName?[i] ?? fileName;
      formData.files.add(MapEntry<String, MultipartFile>(
        field,
        await MultipartFile.fromFile(file.path, filename: field),
      ));
    }
    return formData;
  }

  /// Exchanges the stored refresh token for a new pair and persists both.
  /// Returns the new refresh token, or null when the session is no longer
  /// valid. Network failures are rethrown so callers can tell "offline" apart
  /// from "logged out".
  static Future<String?> refreshToken() async {
    await AppShared.getRefreshToken();
    if (AppShared.refreshToken.isEmpty) return null;

    final Response<dynamic> response = await _dio.post<dynamic>(
      ApiPaths.refreshTokens,
      data: <String, dynamic>{'refresh_token': AppShared.refreshToken},
      options: _options(false, contentType: jsonType),
    );

    final dynamic data = response.data is Map ? response.data['data'] : null;
    if (response.statusCode == 201 && data is Map) {
      await AppShared.setToken(data['access_token'] as String);
      await AppShared.setRefreshToken(data['refresh_token'] as String);
      return data['refresh_token'] as String;
    }
    return null;
  }
}
