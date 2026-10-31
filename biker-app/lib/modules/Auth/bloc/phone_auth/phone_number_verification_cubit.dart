import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/modules/notification/widget/firebase_notification.dart';
import 'package:thewhsherbiker/shared/services/firebase_authentication_service.dart';

part 'phone_number_verification_state.dart';

class PhoneNumberVerificationCubit extends Cubit<PhoneNumberVerificationState> {
  PhoneNumberVerificationCubit()
    : super(const PhoneNumberVerificationInitialState());

  static final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();

  Future<void> requestOTP({required String phoneNumber}) async {
    emit(const RequestOTPLoadingState());

    debugPrint('Phone number doesn\'t exists, requesting OTP');
    await _firebaseAuthenticationService.firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      codeSent: (String verificationId, int? resendToken) {
        emit(AskUserForOTPCodeState(verificationId: verificationId));
      },
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Error Login Phone====> ${e.code}");

        if (e.code == 'phone-number-already-exists') {
          emit(const PhoneNumberAlreadyExistsState());
        } else if (e.code == 'invalid-phone-number') {
          emit(const PhoneNumberIsInvalidState());
        } else if (e.code == 'too-many-requests_tab') {
          emit(const PhoneNumberHasBeenBlockedForTooManyRequestsState());
        } else {
          emit(const PhoneNumberHasBeenBlockedForTooManyRequestsState());
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        emit(OTPAutoRetrievalTimeoutState(verificationId));
      },
    );
  }

  Future<void> resendOTPRequest({required String phoneNumber}) async {
    emit(const RequestOTPLoadingState());
    debugPrint('Phone number doesn\'t exists, requesting OTP');
    await _firebaseAuthenticationService.firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      codeSent: (String verificationId, int? resendToken) {
        emit(OTPResentState(verificationId));
      },
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Error Login Phone====> ${e.code}");

        if (e.code == 'phone-number-already-exists') {
          emit(const PhoneNumberAlreadyExistsState());
        } else if (e.code == 'invalid-phone-number') {
          emit(const PhoneNumberIsInvalidState());
        } else if (e.code == 'too-many-requests_tab') {
          emit(const PhoneNumberHasBeenBlockedForTooManyRequestsState());
        } else {
          emit(RequestOTPUnknownErrorState(e.message));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        emit(OTPAutoRetrievalTimeoutState(verificationId));
      },
    );
  }

  Future<void> verifyPhone({
    required String verificationId,
    required String smsCode,
    required BuildContext context,
    required bool signup,
  }) async {
    emit(const VerifyPhoneNumberLoadingState());
    final FirebaseCloudMessagingService firebaseCloudMessagingService =
        FirebaseCloudMessagingService();
    final String? fcmToken = await firebaseCloudMessagingService.getFcmToken();
    AppShared.fcmToken = fcmToken;
    try {
      final PhoneAuthCredential phoneAuthCredential =
          PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );

      if (_firebaseAuthenticationService.firebaseAuth.currentUser != null) {
        await _firebaseAuthenticationService.firebaseAuth.signInWithCredential(
          phoneAuthCredential,
        );
      } else {
        await _firebaseAuthenticationService.firebaseAuth.signInWithCredential(
          phoneAuthCredential,
        );
      }
      if (signup) {
      } else {}
      emit(PhoneNumberVerifiedSuccessfullyState(fcmToken: fcmToken!));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked' ||
          e.code == 'credential-already-in-use') {
        emit(const PhoneNumberLinkingErrorState());
      } else if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        emit(const OTPCodeIsInvalidState());
      } else {
        emit(PhoneNumberVerificationUnknownErrorState(e.message));
      }
    } catch (e) {
      emit(PhoneNumberVerificationUnknownErrorState(e.toString()));
    }
  }
}
