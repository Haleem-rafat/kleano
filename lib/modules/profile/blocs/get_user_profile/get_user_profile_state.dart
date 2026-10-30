part of 'get_user_profile_bloc.dart';

class GetUserProfileState {
  const GetUserProfileState();
}

class GetUserProfileInitial extends GetUserProfileState {}

class GetUserProfileLoading extends GetUserProfileState {}

class GetUserProfileSuccess extends GetUserProfileState {
  UserProfile userProfile;
  GetUserProfileSuccess({required this.userProfile}) {
    print(userProfile.toJson());
  }
}

class GetUserProfileFailed extends GetUserProfileState {
  final String error;

  GetUserProfileFailed({required this.error});
}

class GetUserProfileConnectionError extends GetUserProfileState {}
