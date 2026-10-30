part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class BikerProfileLoading extends ProfileState {}

class BikerProfileSuccess extends ProfileState {
  final ProfileModel profile;

  BikerProfileSuccess({required this.profile});
}

class BikerProfileFailed extends ProfileState {
  final String error;

  BikerProfileFailed({required this.error});
}

class BikerProfileEditLoading extends ProfileState {}

class BikerProfileEditSuccess extends ProfileState {}

class BikerProfileEditFailed extends ProfileState {
  final String error;

  BikerProfileEditFailed({required this.error});
}

///////// Change Language
class ChangeBikerLanguageLoading extends ProfileState {}

class ChangeBikerLanguageSuccess extends ProfileState {}

class ChangeBikerLanguageFailed extends ProfileState {
  final ErrorModel? errorModel;
  final String? error;
  ChangeBikerLanguageFailed({this.errorModel, this.error});
}

class BikerGetTotalWashesSuccess extends ProfileState {
  final int totalWashes;

  BikerGetTotalWashesSuccess({required this.totalWashes});
}

class BikerGetTotalWashesFailed extends ProfileState {
  final String error;
  BikerGetTotalWashesFailed({required this.error});
}

class BikerGetTotalWashesLoading extends ProfileState {}

class BikerGetTotalCommissionSuccess extends ProfileState {
  final TotalCommissionModel totalCommission;

  BikerGetTotalCommissionSuccess({required this.totalCommission});
}

class BikerGetTotalCommissionFailed extends ProfileState {
  final String error;
  BikerGetTotalCommissionFailed({required this.error});
}

class BikerGetTotalCommissionLoading extends ProfileState {}

class BikerGetScheduleLoading extends ProfileState {}

class BikerGetScheduleSuccess extends ProfileState {
  final BikerScheduleModel schedule;

  BikerGetScheduleSuccess({required this.schedule});
}

class BikerGetScheduleFailed extends ProfileState {
  final String error;
  BikerGetScheduleFailed({required this.error});
}
