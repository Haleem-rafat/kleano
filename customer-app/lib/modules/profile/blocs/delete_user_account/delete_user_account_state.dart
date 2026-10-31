part of 'delete_user_account_bloc.dart';

class DeleteUserAccountState {
  const DeleteUserAccountState();
}

class DeleteAccountInitial extends DeleteUserAccountState {}

class DeleteAccountLoading extends DeleteUserAccountState {}

class DeleteAccountSuccess extends DeleteUserAccountState {}

class DeleteAccountFailed extends DeleteUserAccountState {
  final String error;
  //  List<DeleteMessages>? deleteMessages;
  //  List<DeleteErrors>? deleteErrors;
  // // final DeleteUserAccount deleteUserAccount;
  DeleteAccountFailed({
    required this.error,
    // required this.deleteUserAccount
    //  this.deleteMessages,
    //  this.deleteErrors,
  });
}

class DeleteAccountConnectionError extends DeleteUserAccountState {}
