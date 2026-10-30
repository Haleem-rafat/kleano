import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMap{
  static final LocationMap _singleton =  LocationMap._internal();
  factory LocationMap() {
    return _singleton;
  }

  LocationMap._internal();

  LatLng newLocation =  const LatLng(0, 0);
  bool search = false;
  List<Marker> markers = <Marker>[];
}