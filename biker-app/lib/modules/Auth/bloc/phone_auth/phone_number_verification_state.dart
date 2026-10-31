part of 'phone_number_verification_cubit.dart';

abstract class PhoneNumberVerificationState {
  const PhoneNumberVerificationState();
}

//Initial state
class PhoneNumberVerificationInitialState extends PhoneNumberVerificationState {
  const PhoneNumberVerificationInitialState();
}

class RequestOTPLoadingState extends PhoneNumberVerificationState {
  const RequestOTPLoadingState();
}

class RequestOTPSignUpLoadingState extends PhoneNumberVerificationState {}

//Request OTP error states
class PhoneNumberAlreadyExistsState extends PhoneNumberVerificationState {
  const PhoneNumberAlreadyExistsState();
}

class PhoneNumberAlreadyExistsSignUpState
    extends PhoneNumberVerificationState {}

class PhoneNumberIsInvalidState extends PhoneNumberVerificationState {
  const PhoneNumberIsInvalidState();
}

class PhoneNumberIsInvalidSignUpState extends PhoneNumberVerificationState {}

class PhoneNumberHasBeenBlockedForTooManyRequestsState
    extends PhoneNumberVerificationState {
  const PhoneNumberHasBeenBlockedForTooManyRequestsState();
}

class PhoneNumberHasBeenBlockedForTooManyRequestsSignUpState
    extends PhoneNumberVerificationState {}

class RequestOTPUnknownErrorState extends PhoneNumberVerificationState {
  final String? error;
  const RequestOTPUnknownErrorState(this.error);
}

class RequestOTPUnknownErrorSignUpState extends PhoneNumberVerificationState {
  final String? error;
  const RequestOTPUnknownErrorSignUpState(this.error);
}

//Request OTP success
class AskUserForOTPCodeState extends PhoneNumberVerificationState {
  final String verificationId;
  const AskUserForOTPCodeState({required this.verificationId});
}

class AskUserForOTPCodeSignupState extends PhoneNumberVerificationState {
  final String verificationId;
  const AskUserForOTPCodeSignupState({required this.verificationId});
}

class VerifyPhoneNumberLoadingState extends PhoneNumberVerificationState {
  const VerifyPhoneNumberLoadingState();
}

class PhoneNumberLinkingErrorState extends PhoneNumberVerificationState {
  const PhoneNumberLinkingErrorState();
}

class OTPCodeIsInvalidState extends PhoneNumberVerificationState {
  const OTPCodeIsInvalidState();
}

class PhoneNumberVerificationUnknownErrorState
    extends PhoneNumberVerificationState {
  final String? error;
  const PhoneNumberVerificationUnknownErrorState(this.error);
}

class PhoneNumberVerifiedSuccessfullyState
    extends PhoneNumberVerificationState {
  final String fcmToken;
  const PhoneNumberVerifiedSuccessfullyState({required this.fcmToken});
}

class OTPResentState extends PhoneNumberVerificationState {
  final String verificationId;
  const OTPResentState(this.verificationId);
}

class OTPAutoRetrievalTimeoutState extends PhoneNumberVerificationState {
  final String verificationId;
  const OTPAutoRetrievalTimeoutState(this.verificationId);
}

class OTPAutoRetrievalTimeoutSignUpState extends PhoneNumberVerificationState {
  final String verificationId;
  const OTPAutoRetrievalTimeoutSignUpState(this.verificationId);
}
