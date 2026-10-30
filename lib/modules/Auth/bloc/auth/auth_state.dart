part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}
class BikerLoginLoading extends AuthState {}
class BikerLoginSuccess extends AuthState {
  final AuthModel authModel;

  BikerLoginSuccess({required this.authModel});
}
class BikerLoginFailed extends AuthState {
  final String error;

  BikerLoginFailed({required this.error});
}

class BikerCheckPhoneLoading extends AuthState {}
class BikerCheckPhoneSuccess extends AuthState {
  final String token;

  BikerCheckPhoneSuccess({required this.token});
}
class BikerCheckPhoneFailed extends AuthState {
  final String error;

  BikerCheckPhoneFailed({required this.error});
}

class BikerResetPasswordLoading extends AuthState {}
class BikerResetPasswordSuccess extends AuthState {}
class BikerResetPasswordFailed extends AuthState {
  final String error;

  BikerResetPasswordFailed({required this.error});
}

class BikerUpdatePasswordLoading extends AuthState {}
class BikerUpdatePasswordSuccess extends AuthState {}
class BikerUpdatePasswordFailed extends AuthState {
  final String error;

  BikerUpdatePasswordFailed({required this.error});
}

/*class BikerProfileLoading extends AuthState {}
class BikerProfileSuccess extends AuthState {
  final ProfileModel profile;

  BikerProfileSuccess({required this.profile});
}
class BikerProfileFailed extends AuthState {
  final String error;

  BikerProfileFailed({required this.error});
}*/

/*class BikerProfileEditLoading extends AuthState {}
class BikerProfileEditSuccess extends AuthState {}
class BikerProfileEditFailed extends AuthState {
  final String error;

  BikerProfileEditFailed({required this.error});
}*/


class BikerLogOutLoading extends AuthState {}
class BikerLogOutSuccess extends AuthState {}
class BikerLogOutFailed extends AuthState {
  final String error;

  BikerLogOutFailed({required this.error});
}


class BikerSplashLoading extends AuthState{}
class BikerSplashAlreadyUser extends AuthState{}
class BikerSplashExpiredToken extends AuthState{}
class BikerSplashNotUser extends AuthState{}
