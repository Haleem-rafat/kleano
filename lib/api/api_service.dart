import 'dart:developer';
import 'dart:io';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:thewasher/api/Interceptor.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/app_config.dart';

class ApiService {
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.getAppBaseUrl(),
      ),
    );

    dio.interceptors.add(ChuckerDioInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          responseBody: true,
          requestBody: true,
          logPrint: (Object? object) => log(object.toString(), name: 'HTTP'),
        ),
      );
    }
    dio.interceptors.add(AuthInterceptor(dio: dio));
    return dio;
  }

  static Future<Response<T>?> getApi<T>(String path,
      {Map<String, dynamic>? params, bool isAuth = true}) async {
    return await _dio.get<T>(
      path,
      queryParameters: params,
      options: Options(
        extra: {"requiresAuth": isAuth},
      ),
    );
  }

  static Future<Response<T>?> postApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return await _dio.post<T>(
      path,
      data: body,
      options: Options(
        extra: {"requiresAuth": isAuth},
        contentType: isJson ? 'application/json' : 'multipart/form-data',
      ),
    );
  }

  static Future<Response> refreshToken(String refreshToken) async {
    log('----------refresh Token called -------------');
    var response = await _dio.post(
      ApiPaths.refreshTokens,
      options: Options(
        extra: {"requiresAuth": false},
        headers: {
          "Authorization": 'Bearer $refreshToken',
        },
      ),
    );

    return response;
  }

  static Future<Response<T>?> deleteApi<T>(
    String path, {
    dynamic data,
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      options: Options(
        extra: {"requiresAuth": isAuth},
        contentType: isJson ? 'application/json' : 'multipart/form-data',
      ),
    );
  }

  static Future<Response<T>?> patchApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return await _dio.patch<T>(
      path,
      data: body,
      options: Options(
        extra: {"requiresAuth": isAuth},
        contentType: isJson ? 'application/json' : 'multipart/form-data',
      ),
    );
  }

  static Future<Response<T>?> putApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    return await _dio.put<T>(
      path,
      data: body,
      options: Options(
        extra: {"requiresAuth": isAuth},
        contentType: isJson ? 'application/json' : 'multipart/form-data',
      ),
    );
  }

  static Future<Response<T>?> putMultiPartApi<T>(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    List<String?>? filesName,
    List<File>? files,
    bool isJson = true,
    bool isAuth = false,
    bool hasUserId = true,
  }) async {
    final FormData formData = FormData();
    body.forEach((String key, dynamic value) {
      if (value is List) {
        value.forEach((e) {
          formData.fields.add(MapEntry<String, String>(key, e.toString()));
        });
      } else {
        formData.fields.add(
          MapEntry<String, String>(key, value.toString()),
        );
      }
    });

    if (files != null && files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        final String fileName = files[i].path.split('/').last;
        formData.files.add(
          MapEntry<String, MultipartFile>(
            filesName![i] ?? fileName,
            MultipartFile.fromFileSync(files[i].path,
                filename: filesName[i] ?? fileName),
          ),
        );
      }
    }

    return await _dio.put<T>(
      path,
      data: formData,
      options: Options(
        extra: {"requiresAuth": isAuth},
        contentType: isJson ? 'application/json' : 'multipart/form-data',
      ),
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
    final FormData formData = FormData();
    body.forEach((String key, dynamic value) {
      if (value is List) {
        value.forEach((e) {
          formData.fields.add(MapEntry<String, String>(key, e.toString()));
        });
      } else {
        formData.fields.add(
          MapEntry<String, String>(key, value.toString()),
        );
      }
    });

    if (files != null && files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        final String fileName = files[i].path.split('/').last;
        formData.files.add(
          MapEntry<String, MultipartFile>(
            filesName![i] ?? fileName,
            MultipartFile.fromFileSync(files[i].path,
                filename: filesName[i] ?? fileName),
          ),
        );
      }
    }

    return await _dio.post<T>(
      path,
      data: formData,
      options: Options(
        extra: {"requiresAuth": isAuth},
        contentType: isJson ? 'application/json' : 'multipart/form-data',
      ),
    );
  }
}
