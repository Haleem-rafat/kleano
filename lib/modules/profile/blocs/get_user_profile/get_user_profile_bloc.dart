import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/data/repo/profile_repo.dart';
import 'package:thewasher/modules/profile/data/responses/user_profile.dart';
part 'get_user_profile_event.dart';
part 'get_user_profile_state.dart';
String? userId;
num? walletBalance;
num? points;
bool? isAllowedNotifications;
class GetUserProfileBloc
    extends Bloc<GetUserProfileEvent, GetUserProfileState> {
   Profile profile = Profile();

  GetUserProfileBloc() : super(GetUserProfileInitial()) {
    on<GetUserProfileEvent>((event, emit) async {
      try {
        if(event.isRefresh){
           emit(GetUserProfileLoading());
        }
        ProfileResponse response = await ProfileRepo.getUserProfile();

        if (response.success) {
          final UserProfile result = response.result!;
          profile = response.result!.data!;
          userId = result.data?.sId;
          walletBalance = result.data?.walletBalance;
          points = result.data?.points;
          isAllowedNotifications = result.data?.isAllowNotification;
          emit(GetUserProfileSuccess(userProfile: result));
        } else {
          emit(GetUserProfileFailed(error: response.message));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(GetUserProfileConnectionError());
        } else {
          emit(GetUserProfileFailed(error: e.message ?? ""));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(GetUserProfileConnectionError());
        } else {
          emit(GetUserProfileFailed(error: e.toString()));
        }
      }
    });
 }
}
