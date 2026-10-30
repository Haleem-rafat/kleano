import 'package:thewasher/core/enums/status.dart';

class AuthState {
  final RequestStatus? signUpStatus;
  final RequestStatus? loginStatus;
  final RequestStatus? logoutStatus;
  final RequestStatus? sendOTPStatus;
  final RequestStatus? verifyOTPStatus;
  final RequestStatus? resendRegisterOTPStatus;
  final String? loginErrorMessage;
  final String? logoutErrorMessage;
  final String? sendOTPErrorMessage;
  final String? signUpErrorMessage;
  final String? verifyOTPErrorMessage;
  final String? resendRegisterOTPErrorMessage;

  AuthState({
    this.signUpStatus,
    this.loginStatus,
    this.logoutStatus,
    this.sendOTPStatus,
    this.verifyOTPStatus,
    this.resendRegisterOTPStatus,
    this.logoutErrorMessage,
    this.loginErrorMessage,
    this.sendOTPErrorMessage,
    this.signUpErrorMessage,
    this.verifyOTPErrorMessage,
    this.resendRegisterOTPErrorMessage,
  });

  AuthState copyWith({
    RequestStatus? signUpStatus,
    RequestStatus? loginStatus,
    RequestStatus? logoutStatus,
    RequestStatus? sendOTPStatus,
    RequestStatus? verifyOTPStatus,
    RequestStatus? resendRegisterOTPStatus,
    String? logoutErrorMessage,
    String? loginErrorMessage,
    String? sendOTPErrorMessage,
    String? signUpErrorMessage,
    String? verifyOTPErrorMessage,
    String? resendRegisterOTPErrorMessage,
  }) {
    return AuthState(
      signUpStatus: signUpStatus ?? this.signUpStatus,
      loginStatus: loginStatus ?? this.loginStatus,
      logoutStatus: logoutStatus ?? this.logoutStatus,
      sendOTPStatus: sendOTPStatus ?? this.sendOTPStatus,
      verifyOTPStatus: verifyOTPStatus ?? this.verifyOTPStatus,
      resendRegisterOTPStatus: resendRegisterOTPStatus ?? this.resendRegisterOTPStatus,
      logoutErrorMessage: logoutErrorMessage ?? this.logoutErrorMessage,
      loginErrorMessage: loginErrorMessage ?? this.loginErrorMessage,
      sendOTPErrorMessage: sendOTPErrorMessage ?? this.sendOTPErrorMessage,
      signUpErrorMessage: signUpErrorMessage ?? this.signUpErrorMessage,
      verifyOTPErrorMessage:
          verifyOTPErrorMessage ?? this.verifyOTPErrorMessage,
      resendRegisterOTPErrorMessage:
          resendRegisterOTPErrorMessage ?? this.resendRegisterOTPErrorMessage,
    );
  }
}
