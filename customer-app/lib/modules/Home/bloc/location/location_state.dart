part of 'location_bloc.dart';

@immutable
abstract class LocationState {}

class LocationInitial extends LocationState {}

class UpdateUserLocationLoading extends LocationState {}

class UpdateUserLocationSuccess extends LocationState {}

class UpdateUserLocationFailed extends LocationState {
  final String error;

  UpdateUserLocationFailed({required this.error});
}

///////////////////////////////////////////////////////////////

class GetSavedLocationLoading extends LocationState {}

class GetSavedLocationSuccess extends LocationState {
  final List<AddressModel> savedLocation;

  GetSavedLocationSuccess({required this.savedLocation});

  GetSavedLocationSuccess copyWith({
    List<AddressModel>? savedLocation,
  }) {
    return GetSavedLocationSuccess(
      savedLocation: savedLocation ?? this.savedLocation,
    );
  }
}

class GetSavedLocationFailed extends LocationState {
  final String error;

  GetSavedLocationFailed({required this.error});
}

////////////////////////////////////////////////////////////////
class SaveLocationLoading extends LocationState {}

class SaveLocationSuccess extends LocationState {
  final AddressModel saved;

  SaveLocationSuccess({required this.saved});
}

class SaveLocationFailed extends LocationState {
  final String error;

  SaveLocationFailed({required this.error});
}

///////////////////////////////////////////////////////////////
class UnSaveLocationLoading extends LocationState {}

class UnSaveLocationSuccess extends LocationState {}

class UnSaveLocationFailed extends LocationState {
  final String error;

  UnSaveLocationFailed({required this.error});
}

/////////////////////////////////////////////////////////////////
class ClearSaveLocationLoading extends LocationState {}

class ClearSaveLocationSuccess extends LocationState {}

class ClearSaveLocationFailed extends LocationState {
  final String error;

  ClearSaveLocationFailed({required this.error});
}

////////////////////////////////////////////////////////////////

class GetRecentLocationLoading extends LocationState {}

class GetRecentLocationSuccess extends LocationState {
  final List<AddressModel> recentLocation;

  GetRecentLocationSuccess({required this.recentLocation});
}

class GetRecentLocationFailed extends LocationState {
  final String error;

  GetRecentLocationFailed({required this.error});
}

////////////////////////////////////////////////////////////////

class SetDefaultLocationLoading extends LocationState {}

class SetDefaultLocationSuccess extends LocationState {
  final List<AddressModel>? updatedSavedLocations;

  SetDefaultLocationSuccess({this.updatedSavedLocations});
}

class SetDefaultLocationFailed extends LocationState {
  final String error;

  SetDefaultLocationFailed({required this.error});
}

////////////////////////////////////////////////////////////////

class SaveRecentLocationLoading extends LocationState {}

class SaveRecentLocationSuccess extends LocationState {
  final AddressModel savedLocation;

  SaveRecentLocationSuccess({required this.savedLocation});
}

class SaveRecentLocationFailed extends LocationState {
  final String error;

  SaveRecentLocationFailed({required this.error});
}

////////////////////////////////////////////////////////////////

class GetOffersLoading extends LocationState {}

class GetOffersSuccess extends LocationState {}

class GetOffersFailed extends LocationState {}

////////////////////////////////////////////////////////////////

class GoToLocationLoading extends LocationState {}

class GoToLocationSuccess extends LocationState {}

class GoToLocationFailed extends LocationState {
  final String error;

  GoToLocationFailed({required this.error});
}

/////////////////////////////////////////////////////////////////

class SavePickedLocationLoading extends LocationState {}

class SavePickedLocationSuccess extends LocationState {}

class SavePickedLocationFailed extends LocationState {
  final String error;

  SavePickedLocationFailed({required this.error});
}

////////////////////////////////////////////////////////////////

class GetDefaultLocationLoading extends LocationState {}

class GetDefaultLocationSuccess extends LocationState {
  final LatLng defaultLocation;

  GetDefaultLocationSuccess({required this.defaultLocation});
}

class GetDefaultLocationFailed extends LocationState {
  final String error;

  GetDefaultLocationFailed({required this.error});
}

////////////////////////////////////////////////////////////////

class DeleteLocationByIdLoading extends LocationState {}

class DeleteLocationByIdSuccess extends LocationState {}

class DeleteLocationByIdFailed extends LocationState {
  final String error;

  DeleteLocationByIdFailed({required this.error});
}