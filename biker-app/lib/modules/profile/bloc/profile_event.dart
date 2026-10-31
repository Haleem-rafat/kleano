part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class BikerProfile extends ProfileEvent {}

class BikerUpdateStatus extends ProfileEvent {
  final String status;

  BikerUpdateStatus({required this.status});
}

class BikerProfileEdit extends ProfileEvent {
  final String name;
  final String image;

  BikerProfileEdit({required this.name, required this.image});
}

class UpdateBikerLanguage extends ProfileEvent {
  final String languageCode;

  UpdateBikerLanguage({required this.languageCode});
}

class BikerGetTotalWashes extends ProfileEvent {
  final String status;

  BikerGetTotalWashes({required this.status});
}

class BikerGetTotalCommission extends ProfileEvent {}

class BikerGetSchedule extends ProfileEvent {}
