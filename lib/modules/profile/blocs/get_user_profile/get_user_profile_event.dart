part of 'get_user_profile_bloc.dart';

class GetUserProfileEvent {
  final bool isRefresh;
  GetUserProfileEvent({this.isRefresh = true});
}

class FetchPersonalInfo extends GetUserProfileEvent{}
