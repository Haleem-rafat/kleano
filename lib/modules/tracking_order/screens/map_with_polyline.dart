import 'dart:async';

import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class TrackingBikerOnTheWay extends StatefulWidget {
  const TrackingBikerOnTheWay({super.key});

  @override
  State<TrackingBikerOnTheWay> createState() => _TrackingBikerOnTheWayState();
}

class _TrackingBikerOnTheWayState extends State<TrackingBikerOnTheWay> {
  late LatLng currentLocation;
  late LatLng destinationLocation;
  late PolylinePoints polylinePoints;
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = <LatLng>[];
  final Set<Marker> _markers = <Marker>{};

  Future<dynamic> onMapCreated(GoogleMapController mapController) async {
    mapController = mapController;
    // ADD map style if you need
    // mapController.setMapStyle(mapStyle);
    // ADD Polylines Future
    // setPolyline();
  }

  // Future<void> setPolyline() async {
  //   // PolylineResult polylineResult =
  //   //     await polylinePoints.getRouteBetweenCoordinates(
  //   //   // Key map
  //   //   '',
  //     PointLatLng(
  //       currentLocation.latitude,
  //       currentLocation.longitude,
  //     ),
  //     PointLatLng(
  //       destinationLocation.latitude,
  //       destinationLocation.longitude,
  //     ),
  //   );
  //   // if( polylineResult.status == 'OK'){

  //   // polylineResult.points.forEach((PointLatLng point) {
  //   //   polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //   // });
  //   setState(() {
  //     _polylines.add(Polyline(
  //       polylineId: const PolylineId('polyline'),
  //       points: polylineCoordinates,
  //       width: 5,
  //       color: Colors.red,
  //       // patterns: [PatternItem.dash(15), PatternItem.gap(5)],
  //     ));
  //   });
  // }

  // }
  Future<void> addMarker() async {
    final BitmapDescriptor markerCurrentLocation =
        await MarkerIcon.markerFromIcon(
            Icons.location_on_rounded, Colors.blue, 70);
    final BitmapDescriptor markerDestinationLocation =
        await MarkerIcon.markerFromIcon(
            Icons.location_on_rounded, Colors.red, 70);
    // final BitmapDescriptor markerDestinationLocation = await MarkerIcon.svgAsset(assetName: 'assets/svg/Mappin.svg', context: context, size: 40);
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: currentLocation,
          icon: markerCurrentLocation,
          flat: true,
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: destinationLocation,
          icon: markerDestinationLocation,
          flat: true,
        ),
      );
    });
  }

//   late Map<MarkerId,Marker> _markers;
//   Map<PolylineId, Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   // PolylinePoints polylinePoints = PolylinePoints();
//  final Completer<GoogleMapController> _controller = Completer();
//  static const CameraPosition _cameraPosition = CameraPosition(
//                 target: LatLng(31.243073106840335, 29.958615804839127),
//                 zoom: 11);

  @override
  void initState() {
    super.initState();
    // _markers = <MarkerId,Marker> {};
    // _markers.clear();
    currentLocation = const LatLng(31.2158281, 29.9455641);
    destinationLocation = const LatLng(31.166623769122523, 29.877893663942814);
    polylinePoints = PolylinePoints();
    addMarker();
  }

  // //Add polylines to the map
  // _addPolyLine(List<LatLng> polylineCoordinates) {
  //   PolylineId id = PolylineId("poly");
  //   Polyline polyline = Polyline(
  //     polylineId: id,
  //     color: Colors.deepOrange,
  //     points: polylineCoordinates,
  //     width: 3,
  //     patterns: [PatternItem.dash(15), PatternItem.gap(10)],
  //   );
  //   polylines[id] = polyline;
  // }
  // _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
  //   MarkerId markerId = MarkerId(id);
  //   Marker marker =
  //       Marker(markerId: markerId, icon: descriptor, position: position);
  //   _markers[markerId] = marker;
  // }

  // _addPolyLine() {
  //   PolylineId id = PolylineId("poly");
  //   Polyline polyline = Polyline(
  //     polylineId: id,
  //     color: Colors.deepOrange,
  //     points: polylineCoordinates,
  //     width: 3,
  //     patterns: [PatternItem.dash(15), PatternItem.gap(10)],
  //   );
  //   polylines[id] = polyline;
  //   setState(() {});
  // }

  //  _getPolyline() async {
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       googleAPiKey,
  //       PointLatLng(_originLatitude, _originLongitude),
  //       PointLatLng(_destLatitude, _destLongitude),
  //       travelMode: TravelMode.driving,
  //       wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   }
  //   _addPolyLine();
  // }
// }
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.darkStatusBarIconsStyle,
      child: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: const CameraPosition(
                target: LatLng(31.2158281, 29.9455641), zoom: 11),
            onMapCreated: onMapCreated,
            markers: _markers,
            // Polylines are handled in onMapCreated function
            polylines: _polylines,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.5.w, vertical: 30.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorManager.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, .16),
                            blurRadius: 6.r,
                            offset: const Offset(0, 3))
                      ]),
                  child: Center(
                      child: Icon(
                    Icons.arrow_back_ios,
                    color: ColorManager.primary,
                    size: 18.w,
                  )),
                ),
                Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorManager.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, .16),
                            blurRadius: 6.r,
                            offset: const Offset(0, 3))
                      ]),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: ColorManager.primary,
                    size: 14.w,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
