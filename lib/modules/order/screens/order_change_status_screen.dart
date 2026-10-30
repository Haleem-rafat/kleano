import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/utilis/map_style.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart'
    as ord;
import 'package:thewhsherbiker/modules/order/widgets/status_order_bottom_sheet.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/screens/profile_screen.dart';
import 'package:thewhsherbiker/modules/profile/widget/biker_status_switch.dart';
import 'package:thewhsherbiker/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class OrderChangeStatus extends StatefulWidget {
  final ord.OrderModel order;
  final int? index;
  final bool notification;
  final BitmapDescriptor? markerBikerLocation;
  final BitmapDescriptor? markerUserLocation;
  const OrderChangeStatus(
      {super.key,
      required this.order,
      this.index,
      required this.notification,
      this.markerBikerLocation,
      this.markerUserLocation});

  @override
  State<OrderChangeStatus> createState() => _OrderChangeStatusState();
}

class _OrderChangeStatusState extends State<OrderChangeStatus> {
  final double _initFabHeight = 120.h;
  double fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 120.h;
  PanelController panelController = PanelController();
  //
  double zoom = 12.5;
  Set<Marker> markers = <Marker>{};
  List<LatLng> points = <LatLng>[];
  List<Polyline> polyline = <Polyline>[];
  // GoogleMapPolyline googleMapPolyline =
  //     GoogleMapPolyline(apiKey: AppConfig.kApiKey);
  List<LatLng> routes = <LatLng>[];
  late StreamSubscription<Position> positionStream;

  void getCurrentLocation(BitmapDescriptor markerBikerLocation,
      BitmapDescriptor markerUserLocation) async {
    positionStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
        .listen((Position position) async {
      debugPrint("llll ${position.latitude} ${position.longitude}");
      sl<AuthBloc>().currentPosition =
          LatLng(position.latitude, position.longitude);
      debugPrint(
          "llll2 ${sl<AuthBloc>().currentPosition.latitude} ${sl<AuthBloc>().currentPosition.longitude}");
      setState(() {
        markers.clear();
        polyline.clear();
        markers.add(
          Marker(
            markerId: const MarkerId("biker"),
            position: LatLng(sl<AuthBloc>().currentPosition.latitude,
                sl<AuthBloc>().currentPosition.longitude),
            icon: markerBikerLocation,
            flat: true,
          ),
        );
        markers.add(
          Marker(
            markerId: const MarkerId("user"),
            position: LatLng(sl<HomeBloc>().orderDetails.location!.latitude!,
                sl<HomeBloc>().orderDetails.location!.longitude!),
            icon: markerUserLocation,
            flat: true,
          ),
        );

        polyline.add(Polyline(
          polylineId: PolylineId('route'),
          points: routes,
          patterns: <PatternItem>[PatternItem.dot],
          width: 4,
          color: ColorManager.medGray,
          startCap: Cap.roundCap,
        ));
      });

      if (sl<HomeBloc>().orderStep == 0) {
        debugPrint("on the way");
        sl<HomeBloc>()
            .socketService
            .emit("biker:location-changes", <String, Object?>{
          "order": sl<HomeBloc>().orderDetails.sId,
          "latitude": sl<AuthBloc>().currentPosition.latitude,
          "longitude": sl<AuthBloc>().currentPosition.longitude,
          "streetName": "dataValue",
          "subAdministrativeArea": "dataValue",
        });
      } else if (sl<HomeBloc>().orderStep == 1) {
        debugPrint("Arrived");
        positionStream.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fabHeight = _initFabHeight;
    if (widget.notification) {
      _handleNotification();
    } else {
      _handleOrder();
    }
  }

  void _handleNotification() {
    final BitmapDescriptor? bikerLocation = widget.markerBikerLocation;
    final BitmapDescriptor? userLocation = widget.markerUserLocation;

    if (bikerLocation != null && userLocation != null) {
      getCurrentLocation(bikerLocation, userLocation);
    }
  }

  void _handleOrder() {
    final String? orderId = widget.order.sId;

    if (orderId != null) {
      sl<HomeBloc>().add(BikerOrder(orderId: orderId, context: context));
    }
  }

  Future<dynamic> onMapCreated(GoogleMapController mapController) async {
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .60;
    _panelHeightClosed = MediaQuery.of(context).size.height * .21;
    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) {
          if (state is BikerOrderSuccess) {
            getCurrentLocation(
                state.markerBikerLocation, state.markerUserLocation);
          } else if (state is BikerCompleteOrderSuccess) {
            AlertHelper.ratingDialog(context, state.orderId);
          } else if (state is BikerCancelOrderSuccess) {
            positionStream.cancel();
            showSnackBar(
              buildContext: context,
              message: translate(AppStrings.cancelOrderSuccess),
            );
            pop(context);
          } else if (state is BikerCancelOrderFailed) {
            showSnackBar(
              buildContext: context,
              message: state.error,
            );
          }
        },
        builder: (BuildContext context, HomeState state) {
          if (state is BikerOrderLoading) {
            return Center(
              child: LoadingWidget(),
            );
          } else if (state is! BikerOrderFailed) {
            return SlidingUpPanel(
              controller: panelController,
              maxHeight: _panelHeightOpen,
              minHeight: _panelHeightClosed,
              parallaxEnabled: true,
              parallaxOffset: .3,
              panel: StatusOrderBottomSheet(
                order: widget.order,
                index: widget.index ?? -1,
              ),
              body: _mapbody(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              onPanelSlide: (double pos) => setState(() {
                fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                    _initFabHeight;
              }),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Stack _mapbody(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: GoogleMap(
            style: mapStyle,
            onMapCreated: onMapCreated,
            markers: markers,
            polylines: Set.from(polyline),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: sl<AuthBloc>().currentPosition,
              zoom: zoom,
            ),
          ),
        ),
        Positioned(
          top: 46.h,
          right: 18.w,
          left: 18.w,
          child: _bikerDetailsHeader(context),
        )
      ],
    );
  }

  Row _bikerDetailsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(
          onTap: () {
            pushPage(context, ProfileScreen());
          },
          child: CircleImageShared(
              imageUrl: sl<ProfileBloc>().profile.imageLink!,
              radius: 20.r,
              name: sl<ProfileBloc>().profile.userName!),
        ),
        BikerStatusSwitchWidget(),
        InkWell(
          onTap: () {
            positionStream.cancel();
            pop(context);
          },
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: ColorManager.black.withValues(alpha: .07),
                      blurRadius: 6.r,
                      offset: const Offset(0, 3))
                ]),
            child: Icon(
              Icons.close,
              color: ColorManager.primary,
              size: 18.r,
            ),
          ),
        ),
      ],
    );
  }
}
