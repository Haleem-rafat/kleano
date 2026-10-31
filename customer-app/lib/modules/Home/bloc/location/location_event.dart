part of 'location_bloc.dart';

@immutable
abstract class LocationEvent {}

class UpdateUserLocation extends LocationEvent {
  final String latitude;
  final String longitude;
  final String streetName;
  final String subAdministrativeArea;
  final String country;

  UpdateUserLocation({
    required this.latitude,
    required this.longitude,
    required this.streetName,
    required this.subAdministrativeArea,
    required this.country,
  });
}

class GetSavedLocation extends LocationEvent {}

class SaveLocation extends LocationEvent {
  String latitude;
  String longitude;
  String streetName;
  String subAdministrativeArea;
  String country;
  String savedName;

  SaveLocation({
    required this.latitude,
    required this.longitude,
    required this.streetName,
    required this.subAdministrativeArea,
    required this.country,
    required this.savedName,
  });
}

class SetDefaultLocation extends LocationEvent {
  String locationId;
  SetDefaultLocation({required this.locationId});
}

class UnSaveLocation extends LocationEvent {
  String id;
  int index;
  String? type;
  UnSaveLocation({required this.id, required this.index, required this.type});
}

class ClearSavedLocation extends LocationEvent {}

class GetRecentLocation extends LocationEvent {}

class SaveRecentLocation extends LocationEvent {
  String id;
  String savedName;
  int index;

  SaveRecentLocation(
      {required this.id, required this.savedName, required this.index});
}

class GetOffers extends LocationEvent {}

class GoToLocation extends LocationEvent {
  final double latitude;
  final double longitude;
  final String streetName;
  final String subAdministrativeArea;
  final String country;
  final LatLng latLng;
  Completer<GoogleMapController> myController;
  BuildContext context;
  double myZoom;
  bool current;

  GoToLocation({
    required this.latitude,
    required this.longitude,
    required this.streetName,
    required this.subAdministrativeArea,
    required this.country,
    required this.latLng,
    required this.myController,
    required this.context,
    required this.myZoom,
    required this.current,
  });
}

class SavePickedLocation extends LocationEvent {
  PickedLocationModel pickedLocationModel;

  SavePickedLocation({required this.pickedLocationModel});
}

class GetDefaultLocation extends LocationEvent {}

class DeleteLocationById extends LocationEvent {
  String locationId;
  DeleteLocationById({required this.locationId});
}