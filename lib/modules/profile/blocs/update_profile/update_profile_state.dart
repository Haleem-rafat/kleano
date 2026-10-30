part of 'update_profile_bloc.dart';

class UpdateProfileState {
  const UpdateProfileState();
}

class UpdateProfileInitial extends UpdateProfileState {}

class UpdateProfileLoading extends UpdateProfileState {}

class UpdateProfileSuccess extends UpdateProfileState {
  final UserProfile userProfile;
  UpdateProfileSuccess({required this.userProfile});
}

class UpdateProfileFailed extends UpdateProfileState {
  ErrorModel? error;
  UpdateProfileFailed({this.error});
}

class UpdateProfileConnectionError extends UpdateProfileState {}
//////////////

class ChangeUserLanguageLoading extends UpdateProfileState {}

class ChangeUserLanguageSuccess extends UpdateProfileState {}

class ChangeUserLanguageFailed extends UpdateProfileState {
  final ErrorModel? errorModel;
  final String? error;

  ChangeUserLanguageFailed({this.errorModel, this.error});
}
