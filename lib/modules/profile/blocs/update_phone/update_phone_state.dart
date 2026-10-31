part of 'update_phone_bloc.dart';

class UpdatePhoneState {}

class UpdatePhoneInitial extends UpdatePhoneState {}

class UpdatePhoneLoading extends UpdatePhoneState {}

class UpdatePhoneSuccess extends UpdatePhoneState {}

class UpdatePhoneFailed extends UpdatePhoneState {
  final ErrorModel? error;
  UpdatePhoneFailed({this.error});
}

class UpdatePhoneConnectionError extends UpdatePhoneState {}
