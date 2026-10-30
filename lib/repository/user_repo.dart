import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/responses/base_response.dart';
import 'package:thewasher/responses/register_response.dart';

class AuthenticationRepo {
  static Future<BaseResponse> checkPhoneNumber({
    required String phone,
  }) async {
    final Response<dynamic>? response = await ApiService.postApi(
      ApiPaths.checkPhone,
      body: <String, dynamic>{
        "phone": phone,
      },
    );
    return BaseResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<UserRegisterResponse> userRegister({
    required String userName,
    required String email,
    required String phone,
    required String fcmToken,
  }) async {
    final Response<dynamic>? response = await ApiService.postApi(
      ApiPaths.register,
      body: <String, dynamic>{
        "userName": userName,
        "email": email,
        "phone": phone,
        "fcmToken": fcmToken,
      },
    );
    return UserRegisterResponse(
      json: response?.data,
    );
  }

  static Future<UserRegisterResponse> userLogin({
    required String phone,
    required String fcmToken,
  }) async {
    final Response<dynamic>? response = await ApiService.postApi(
      ApiPaths.login,
      body: <String, dynamic>{
        "phone": phone,
        "fcmToken": fcmToken,
      },
    );
    return UserRegisterResponse(
      json: response?.data,
    );
  }

  static Future<BaseResponse> userLogout({
    required String fcmToken,
  }) async {
    final Response<dynamic>? response = await ApiService.postApi(
      ApiPaths.logout,
      body: <String, dynamic>{
        "fcmToken": fcmToken,
      },
      isAuth: true,
    );
    return BaseResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }
}
