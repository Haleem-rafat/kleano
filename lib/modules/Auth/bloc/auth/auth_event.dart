part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class BikerLogin extends AuthEvent {
  final String userName;
  final String passWord;
  final BuildContext context;

  BikerLogin({required this.userName,required this.passWord, required this.context});
}

class BikerCheckPhone extends AuthEvent{
  final String phoneNumber;

  BikerCheckPhone({required this.phoneNumber});
}

class BikerResetPassword extends AuthEvent{
  final String newPassword;
  final String token;

  BikerResetPassword({required this.newPassword , required this.token});
}

class BikerUpdatePassword extends AuthEvent{
  final String oldPassword;
  final String newPassword;
  final BuildContext context;


  BikerUpdatePassword({required this.oldPassword , required this.newPassword,required this.context});
}

class BikerLogOut extends AuthEvent {}

class BikerSplash extends AuthEvent{}
