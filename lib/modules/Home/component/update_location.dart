import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

void updateUserLocation({
  required String latitude,
  required String longitude,
  required String streetName,
  required String subAdministrativeArea,
  required String country,
}) {
  sl<LocationBloc>().add(UpdateUserLocation(
    latitude: latitude,
    longitude: longitude,
    streetName: streetName,
    subAdministrativeArea: subAdministrativeArea,
    country: country,
  ));
}


void currentLocation(Completer<GoogleMapController> myController , double lat , double lng , double myZoom) async {
  final GoogleMapController controller = await myController.future;
  controller.animateCamera(CameraUpdate.newCameraPosition(
    CameraPosition(
      bearing: 0,
      target: LatLng(lat, lng),
      zoom: myZoom,
    ),
  ));
}
