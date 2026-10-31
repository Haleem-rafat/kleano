import 'dart:async';

import 'package:thewasher/core/utilis/marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/utilties/map_style.dart';

class MapScreen extends StatefulWidget {
  final LatLng bikerLocation;
  final Location orderLocation;
  const MapScreen({
    super.key,
    required this.bikerLocation,
    required this.orderLocation,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng orderLocation;
  late LatLng bikerLocation;
  final Set<Polyline> _polylines = <Polyline>{};
  final Set<Marker> _markers = <Marker>{};
  late SocketBloc socketBloc;
  GoogleMapController? _mapController;
  StreamSubscription<SocketState>? _socketUpdates;
  BitmapDescriptor? markerDestinationLocation, markerCurrentLocation;
  // GoogleMapPolyline googleMapPolyline =
  //     GoogleMapPolyline(apiKey: AppConfig.kApiKey);
  List<LatLng> routes = <LatLng>[];
  @override
  void initState() {
    super.initState();
    bikerLocation = LatLng(
      widget.bikerLocation.latitude,
      widget.bikerLocation.longitude,
    );
    orderLocation = LatLng(
      widget.orderLocation.latitude!,
      widget.orderLocation.longitude!,
    );

    socketBloc = BlocProvider.of<SocketBloc>(context);
    _socketUpdates = socketBloc.stream.listen((SocketState socketState) {
      if (socketState is ReceivedAnUpdateBikerOnTheWayState) {
        bikerLocation = LatLng(
          socketState.cameraPosition!.target.latitude,
          socketState.cameraPosition!.target.longitude,
        );
        setState(() {
          _polylines.clear();
          _markers.clear();
          setPolyline(
            LatLng(
              socketState.cameraPosition!.target.latitude,
              socketState.cameraPosition!.target.longitude,
            ),
          );
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('polyline'),
              points: routes,
              width: 3,
              color: KColors.of(context).brand,
              patterns: [PatternItem.dash(15), PatternItem.gap(5)],
            ),
          );
          _markers.add(
            Marker(
              markerId: const MarkerId("currentLocation"),
              position: orderLocation,
              icon: markerCurrentLocation!,
              flat: true,
            ),
          );
          _markers.add(
            Marker(
              markerId: const MarkerId("destination"),
              position: bikerLocation,
              icon: markerDestinationLocation!,
            ),
          );
        });
      }
    });
    Future.delayed(Duration.zero, () {
      addMarker();
    });
  }

  Future<void> setPolyline(LatLng latLng) async {
    try {
      // routes = (await googleMapPolyline.getCoordinatesWithLocation(
      //   origin: LatLng(orderLocation.latitude, orderLocation.longitude),
      //   destination: latLng,
      //   mode: RouteMode.driving,
      // ))!;
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('polyline'),
          points: routes,
          width: 3,
          color: KColors.of(context).brand,
          patterns: [PatternItem.dash(15), PatternItem.gap(5)],
        ),
      );
      setState(() {});
    } catch (error) {
      debugPrint("Error fetching polyline: $error");
      // You can also show a dialog or message to the user if needed
    }
  }

  Future<dynamic> onMapCreated(GoogleMapController mapController) async {
    _mapController = mapController;
    setPolyline(LatLng(bikerLocation.latitude, bikerLocation.longitude));
  }

  Future<void> addMarker() async {
    markerCurrentLocation = await MarkerIcon.svgAsset(
      assetName: AssetsManager.currentLocationPin,
      context: context,
      size: 30,
    );
    //     markerCurrentLocation = await BitmapDescriptor.fromAssetImage(
    //   ImageConfiguration(size: Size(80, 80)),
    //   AssetsManager.locationPin,
    // );
    // MarkerIcon.pictureAsset (assetName: AssetsManager.currentLocationPin, context: context, size: 47.w);

    if (!mounted) return;
    markerDestinationLocation = await MarkerIcon.svgAsset(
      assetName: AssetsManager.bikerPin,
      context: context,
      size: 30,
    );
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: orderLocation,
          icon: markerCurrentLocation!,
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: bikerLocation,
          icon: markerDestinationLocation!,
          flat: true,
        ),
      );
    });
  }

  @override
  void dispose() {
    _socketUpdates?.cancel();
    super.dispose();
    _mapController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      zoomControlsEnabled: false,
      compassEnabled: false,
      initialCameraPosition: CameraPosition(target: orderLocation, zoom: 14),
      style: mapStyle,
      onMapCreated: onMapCreated,
      markers: _markers,
      polylines: _polylines,
    );
  }
}
