import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:thewhsherbiker/api/api_path.dart';
import 'package:thewhsherbiker/api/app_config.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/network/Interceptor.dart';

class ApiService {
  static const String urlEncodedType = 'multipart/form-data';
  static const String jsonType = 'application/json';
  static const int unAuthorizedCode = 403;
  static const int internalServerErrorCode = 500;
  static const String authorizationParameter = 'Authorization';
  static const String bearer = 'Bearer';

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.getAppBaseUrl(),
      ),
    );

    // Logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        logPrint: (Object? object) => log(object.toString(), name: 'HTTP'),
      ),
    );
    dio.interceptors.add(AuthInterceptor(dio: dio));

    // dio.interceptors.add(ChuckerDioInterceptor());

    return dio;
  }

  /// ✅ إعداد التوكين
  static Future<void> _setAuthHeader(Dio dio, bool isAuth) async {
    if (isAuth) {
      await AppShared.getToken();
      dio.options.headers[authorizationParameter] =
          '$bearer ${AppShared.token}';
    }
  }

  static Future<Response<T>?> getApi<T>(String path,
      {bool isAuth = true}) async {
    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final response = await dio.get<T>(
      path,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> getApiSubject<T>(
    String path,
    List<String> educationLevels,
    List<String> secondaryTracks, {
    bool isAuth = true,
  }) async {
    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final queryParameters = {
      'education_levels[]': educationLevels,
      'secondary_tracks[]': secondaryTracks,
    };

    final response = await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> getSchoolFilter<T>(
    String path,
    List<String> city,
    List<String> studentsGender,
    List<String> educationLevels,
    List<String> educationCenters,
    List<String> schoolType, {
    bool isAuth = true,
  }) async {
    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final queryParameters = {
      'city[]': city,
      'students_gender[]': studentsGender,
      'education_levels[]': educationLevels,
      'education_centers[]': educationCenters,
      'school_type[]': schoolType,
    };

    final response = await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> postApi<T>(
    String path, {
    Map<String, dynamic> body = const {},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final response = await dio.post<T>(
      path,
      data: body,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
        contentType: isJson ? jsonType : urlEncodedType,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> deleteApi<T>(
    String path, {
    bool isJson = true,
    bool isAuth = false,
  }) async {
    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final response = await dio.delete<T>(
      path,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
        contentType: isJson ? jsonType : urlEncodedType,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> patchApi<T>(
    String path, {
    Map<String, dynamic> body = const {},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final response = await dio.patch<T>(
      path,
      data: body,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
        contentType: isJson ? jsonType : urlEncodedType,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> putApi<T>(
    String path, {
    Map<String, dynamic> body = const {},
    bool isJson = true,
    bool isAuth = false,
  }) async {
    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final response = await dio.put<T>(
      path,
      data: body,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
        contentType: isJson ? jsonType : urlEncodedType,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> putMultiPartApi<T>(
    String path, {
    Map<String, dynamic> body = const {},
    List<String?>? filesName,
    List<File>? files,
    bool isJson = true,
    bool isAuth = false,
  }) async {
    final formData = FormData();
    body.forEach((key, value) {
      if (value is List) {
        value.forEach((e) {
          formData.fields.add(MapEntry(key, e.toString()));
        });
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    if (files != null && files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        final fileName = files[i].path.split('/').last;
        formData.files.add(
          MapEntry(
            filesName?[i] ?? fileName,
            MultipartFile.fromFileSync(files[i].path,
                filename: filesName?[i] ?? fileName),
          ),
        );
      }
    }

    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final response = await dio.put<T>(
      path,
      data: formData,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
        contentType: urlEncodedType,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> postMultiPartApi<T>(
    String path, {
    Map<String, dynamic> body = const {},
    List<String?>? filesName,
    List<File>? files,
    bool isJson = true,
    bool isAuth = false,
  }) async {
    final formData = FormData();
    body.forEach((key, value) {
      if (value is List) {
        value.forEach((e) {
          formData.fields.add(MapEntry(key, e.toString()));
        });
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    if (files != null && files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        final fileName = files[i].path.split('/').last;
        formData.files.add(
          MapEntry(
            filesName?[i] ?? fileName,
            MultipartFile.fromFileSync(files[i].path,
                filename: filesName?[i] ?? fileName),
          ),
        );
      }
    }

    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final response = await dio.post<T>(
      path,
      data: formData,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
        contentType: urlEncodedType,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<Response<T>?> patchMultiPartApi<T>(
    String path, {
    Map<String, dynamic> body = const {},
    List<String?>? filesName,
    List<File>? files,
    bool isJson = true,
    bool isAuth = false,
  }) async {
    final formData = FormData();
    body.forEach((key, value) {
      if (value is List) {
        value.forEach((e) {
          formData.fields.add(MapEntry(key, e.toString()));
        });
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    if (files != null && files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        final fileName = files[i].path.split('/').last;
        formData.files.add(
          MapEntry(
            filesName?[i] ?? fileName,
            MultipartFile.fromFileSync(files[i].path,
                filename: filesName?[i] ?? fileName),
          ),
        );
      }
    }

    final dio = _createDio();
    await _setAuthHeader(dio, isAuth);

    final response = await dio.patch<T>(
      path,
      data: formData,
      options: Options(
        validateStatus: (status) =>
            status != null && status < internalServerErrorCode,
        contentType: urlEncodedType,
      ),
    );

    if (response.statusCode == unAuthorizedCode) {
      await refreshToken();
      return null;
    }
    return response;
  }

  static Future<String?> refreshToken() async {
    await AppShared.getRefreshToken();
    final response = await postApi(
      ApiPaths.refreshTokens,
      isAuth: false,
      body: {"refresh_token": AppShared.refreshToken},
    );

    if (response != null && response.statusCode == 201) {
      AppShared.setToken(response.data['data']['access_token']);
      return response.data['data']['refresh_token'];
    }
    return null;
  }
}
