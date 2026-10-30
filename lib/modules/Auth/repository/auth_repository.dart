import 'package:flutter/foundation.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/modules/Auth/model/auth_model.dart';

class AuthRepository {
  final ApiService apiService = ApiService();

  Future<void> signup(
      {required String userName,
      required String phone,
      String? email,
      required String fcmToken}) async {
    await ApiService.postApi("/auth/users/register", body: {
      "userName": userName,
      "phone": phone,
      "email": ?email,
      "fcmToken": fcmToken
    });
  }

  Future<AuthModel> login(
      {required String phone,
      required String fcmToken,
      required String otp}) async {
    var res = await ApiService.postApi("/auth/users/login",
        body: {"phone": phone, "fcmToken": fcmToken, "otp": otp});
    AuthModel authModel = AuthModel.fromJson(res!.data['data']);
    debugPrint("AuthModel: $authModel");
    AppShared.setToken(authModel.accessToken);
    AppShared.setRefreshToken(authModel.refreshToken);
    return authModel;
  }

  Future<void> sendOTP({required String phone}) async {
    await ApiService.postApi("/auth/users/send-otp",
        body: {"phone": phone}, isAuth: false);
  }

  Future<void> resendRegisterOTP({required String phone}) async {
    await ApiService.postApi("/auth/pending-users/send-register-otp",
        body: {"phone": phone}, isAuth: false);
  }

  Future<AuthModel> verifySignupOTP(
      {required String otp, required String phone}) async {
    var res = await ApiService.postApi(
        "/auth/pending-users/verify-register-otp",
        body: {"phone": phone, "otp": otp},
        isAuth: false);
    AuthModel authModel = AuthModel.fromJson(res!.data['data']);
    debugPrint("AuthModel: $authModel");
    AppShared.setToken(authModel.accessToken);
    AppShared.setRefreshToken(authModel.refreshToken);
    return authModel;
  }
}
