import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thewhsherbiker/api/api_path.dart';
import 'package:thewhsherbiker/api/api_service.dart';
import 'package:thewhsherbiker/models/error_model.dart';
import 'package:thewhsherbiker/modules/Auth/data/model/auth_model.dart';
import 'package:thewhsherbiker/responses/generic_response.dart';

class AuthRepo {
  static Future<Either<ErrorModel, GenericResponse>> bikerLogin(
      String userName, String password, String fcmToken) async {
    ErrorModel? errorModel;
    debugPrint("Token $fcmToken");
    final Response<dynamic>? response = await ApiService.postApi(ApiPaths.logIn,
        body: {
          'userName': userName,
          'password': password,
          'fcmToken': fcmToken
        });
    if (response!.data['success']) {
      return Right(
          GenericResponse(json: response.data, fromJson: AuthModel.fromJson));
    } else {
      errorModel = ErrorModel.fromJson(response.data['message']);
      return Left(errorModel);
    }
  }

  static Future<String> bikerCheckPhone(String phone) async {
    final Response<dynamic>? response =
        await ApiService.postApi(ApiPaths.checkPhone, body: {
      'phone': phone,
    });
    if (response!.data['isExist']) {
      return response.data['token'];
    } else {
      return "";
    }
  }

  static Future<bool> bikerResetPassword(
      String newPassword, String token) async {
    final Response<dynamic>? response =
        await ApiService.postApi(ApiPaths.resetPassword, body: {
      'newPassword': newPassword,
      'token': token,
    });

    return response!.data['success'];
  }

  static Future<Either<ErrorModel, bool>> bikerUpdatePassword(
      String oldPassword, String newPassword) async {
    ErrorModel? errorModel;
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.updatePassword,
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
      isAuth: true,
    );
    if (response!.data['success']) {
      return Right(response.data['success']);
    } else {
      errorModel = ErrorModel.fromJson(response.data['message']);
      return Left(errorModel);
    }
  }

  static Future<bool> bikerLogOut(String fcmToken) async {
    final Response<dynamic>? response =
        await ApiService.postApi(ApiPaths.logOut,
            body: {
              'fcmToken': fcmToken,
            },
            isAuth: true);

    return response!.data['success'];
  }
}
