import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/data/models/update_profile_request.dart';
import 'package:thewasher/modules/profile/data/repo/profile_repo.dart';
import 'package:thewasher/modules/profile/data/responses/user_profile.dart';
import 'package:thewasher/responses/base_response.dart';

part 'update_profile_event.dart';
part 'update_profile_state.dart';

class UpdateProfileBloc extends Bloc<UpdateProfile, UpdateProfileState> {
  UserProfile userProfile = UserProfile();
  TextEditingController phoneController = TextEditingController();
  String? gender;
  XFile? userImage;
  UpdateProfileBloc() : super(UpdateProfileInitial()) {
    on<UpdateProfileEvent>((event, emit) async {
      try {
        emit(UpdateProfileLoading());

        final ProfileResponse response = await ProfileRepo.updateProfile(request: event.updateProfileRequest);

        if (response.success) {
          emit(UpdateProfileSuccess(userProfile: response.result!));
        } else {
          emit(UpdateProfileFailed(
            error: response.errorModel,
          ));
        }
      } catch (e) {
        emit(UpdateProfileFailed());
      }
    });

    on<UpdateUserLanguage>((event, emit) async {
      try {
        emit(ChangeUserLanguageLoading());

        final BaseResponse response = await ProfileRepo.updateUserLanguage(
          language: event.languageCode,
        );
        if (response.success) {
          emit(ChangeUserLanguageSuccess());
        } else {
          emit(ChangeUserLanguageFailed(
            errorModel: response.errorModel,
            error: response.errorMessage,
          ));
        }
      } catch (e) {
        emit(UpdateProfileFailed());
      }
    });
  }
}
