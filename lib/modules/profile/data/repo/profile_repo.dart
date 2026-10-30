import 'dart:io';
import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/profile/data/models/update_profile_request.dart';
import 'package:thewasher/modules/profile/data/responses/user_profile.dart';
import 'package:thewasher/responses/base_response.dart';

class ProfileRepo {
  static Future<ProfileResponse> getUserProfile() async {
    final Response<dynamic>? response = await ApiService.getApi(
      ApiPaths.users,
      isAuth: true,
    );
    return ProfileResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<ProfileResponse> updateProfile(
      {required UpdateProfileRequest request}) async {
    final Map<String, dynamic> body = {
      'userName': request.userName,
      'email': request.email,
      'gender': request.gender,
    };

    if (request.dob != null) {
      body['dob'] = request.dob;
    }

    final Response<dynamic>? response = await ApiService.putMultiPartApi(
      ApiPaths.users,
      body: body,
      files: request.image != null
          ? <File>[
              request.image!,
            ]
          : null,
      filesName: request.image != null ? ['image'] : null,
      hasUserId: false,
      isAuth: true,
    );
    return ProfileResponse(
      json: response!.data!,
      statusCode: response.statusCode!,
    );
  }

  static Future<BaseResponse> deleteUserAccount() async {
    final Response<dynamic>? response = await ApiService.deleteApi(
      ApiPaths.users,
      isAuth: true,
    );
    return BaseResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<BaseResponse> updatePhoneNumber({required String phone}) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.updatePhoneNumber,
      body: {'phone': phone},
      isAuth: true,
    );
    return BaseResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<BaseResponse> updateUserLanguage(
      {required String language}) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.userLanguage,
      body: {'language': language},
      isAuth: true,
    );
    return BaseResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<BaseResponseWithoutResponse> topupWallet({
    required double amount,
    required Map<String, dynamic> paymentDetails,
  }) async {
    final Map<String, dynamic> body = {
      'amount': amount,
      'paymentDetails': paymentDetails,
    };

    final Response<dynamic>? response = await ApiService.postApi(
      ApiPaths.walletTopup,
      body: body,
      isAuth: true,
    );
    return BaseResponseWithoutResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  // static Future<PromoCodeResponse> getPromoCodes(String status) async {
  //   final Response<dynamic>? response = await ApiService.getApi(
  //     "${ApiPaths.promoCode}?status=$status",
  //     isAuth: true,
  //   );

  //   return PromoCodeResponse(
  //     json: response?.data,
  //     isList: true,
  //   );
  // }
}
