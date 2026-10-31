part of 'update_profile_bloc.dart';

class UpdateProfile {}

class UpdateProfileEvent extends UpdateProfile {
  final UpdateProfileRequest updateProfileRequest;
  UpdateProfileEvent({required this.updateProfileRequest});
}

class UpdateUserLanguage extends UpdateProfile {
  final String languageCode;

  UpdateUserLanguage({required this.languageCode});
}
