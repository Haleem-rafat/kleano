import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:thewasher/core/services/fcm_token.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/Auth/repository/auth_repository.dart';
import 'package:thewasher/repository/user_repo.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState());
  final AuthRepository authRepository = AuthRepository();

  Future<void> signup(
      {required String userName,
      required String phone,
      String? email,
      required String fcmToken}) async {
    emit(state.copyWith(
      signUpStatus: RequestStatus.loading,
      signUpErrorMessage: null,
    ));
    try {
      debugPrint(email);
      await authRepository.signup(
          userName: userName, phone: phone, email: email, fcmToken: fcmToken);
      emit(state.copyWith(signUpStatus: RequestStatus.loaded));
    } catch (e) {
      final msg = _extractErrorMessage(e);
      emit(state.copyWith(
        signUpStatus: RequestStatus.failure,
        signUpErrorMessage: msg,
      ));
      debugPrint(msg);
    }
  }

  Future<void> login(
      {required String phone,
      required String fcmToken,
      required String otp}) async {
    emit(state.copyWith(
      loginStatus: RequestStatus.loading,
      loginErrorMessage: null,
    ));
    try {
      await authRepository.login(phone: phone, fcmToken: fcmToken, otp: otp);
      emit(state.copyWith(loginStatus: RequestStatus.loaded));
    } catch (e) {
      final msg = _extractErrorMessage(e);
      debugPrint(msg);
      emit(state.copyWith(
        loginStatus: RequestStatus.failure,
        loginErrorMessage: msg,
      ));
    }
  }

  Future<void> sendOTP({required String phone}) async {
    emit(state.copyWith(
      sendOTPStatus: RequestStatus.loading,
      sendOTPErrorMessage: null,
    ));
    try {
      await authRepository.sendOTP(phone: phone);
      emit(state.copyWith(sendOTPStatus: RequestStatus.loaded));
    } catch (e) {
      final msg = _extractErrorMessage(e);
      debugPrint(msg);
      emit(state.copyWith(
        sendOTPStatus: RequestStatus.failure,
        sendOTPErrorMessage: msg,
      ));
    }
  }

  Future<void> resendRegisterOTP({required String phone}) async {
    emit(state.copyWith(
      resendRegisterOTPStatus: RequestStatus.loading,
    ));
    try {
      await authRepository.resendRegisterOTP(phone: phone);
      emit(state.copyWith(resendRegisterOTPStatus: RequestStatus.loaded));
    } catch (e) {
      final msg = _extractErrorMessage(e);
      debugPrint(msg);
      emit(state.copyWith(
        resendRegisterOTPStatus: RequestStatus.failure,
        resendRegisterOTPErrorMessage: msg,
      ));
    }
  }

  Future<void> verifySignupOTP({required String otp, required String phone}) async {
    emit(state.copyWith(
      verifyOTPStatus: RequestStatus.loading,
    ));
    try {
      await authRepository.verifySignupOTP(otp: otp, phone: phone);
      emit(state.copyWith(verifyOTPStatus: RequestStatus.loaded));
    } catch (e) {
      final msg = _extractErrorMessage(e);
      debugPrint(msg);
      emit(state.copyWith(
        verifyOTPStatus: RequestStatus.failure,
        verifyOTPErrorMessage: msg,
      ));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(logoutStatus: RequestStatus.loading));
    try {
      // Get FCM token
      String? fcmToken = AppShared.fcmToken;

      if (fcmToken == null || fcmToken.isEmpty) {
        // Try to get it from Firebase Messaging
        fcmToken = await FcmToken.get(apnsWait: const Duration(seconds: 2));
      }

      // Call logout API
      final response = await AuthenticationRepo.userLogout(
        fcmToken: fcmToken ?? "",
      );

      if (response.success) {
        // Clear all local data
        await AppShared.clearAllData();
        emit(state.copyWith(logoutStatus: RequestStatus.loaded));
      } else {
        emit(state.copyWith(
          logoutStatus: RequestStatus.failure,
          logoutErrorMessage: 'Failed to logout. Please try again.',
        ));
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if API call fails, clear local data and logout
      await AppShared.clearAllData();
      emit(state.copyWith(logoutStatus: RequestStatus.loaded));
    }
  }

  String _extractErrorMessage(Object e) {
    if (e is DioException) {
      try {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          final msg = data['message'];
          if (msg is Map) {
            final deviceLang =
                ui.PlatformDispatcher.instance.locale.languageCode;
            final useAr = deviceLang == 'ar';
            final ar = msg['ar']?.toString();
            final en = msg['en']?.toString();
            return useAr
                ? (ar ?? en ?? 'Something went wrong')
                : (en ?? ar ?? 'Something went wrong');
          }
          if (msg is String) return msg;
        }
        return e.message ?? 'Something went wrong';
      } catch (_) {
        return 'Something went wrong';
      }
    }
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.substring(11) : s;
  }
}
