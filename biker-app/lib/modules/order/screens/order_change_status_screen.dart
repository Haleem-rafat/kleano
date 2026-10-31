import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/components/k_swipe_action.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/utilis/map_style.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart'
    as ord;
import 'package:thewhsherbiker/modules/order/widgets/status_order_bottom_sheet.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/screens/profile_screen.dart';
import 'package:thewhsherbiker/modules/profile/widget/biker_status_switch.dart';
import 'package:thewhsherbiker/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class OrderChangeStatus extends StatefulWidget {
  final ord.OrderModel order;
  final int? index;
  final bool notification;
  final BitmapDescriptor? markerBikerLocation;
  final BitmapDescriptor? markerUserLocation;
  const OrderChangeStatus({
    super.key,
    required this.order,
    this.index,
    required this.notification,
    this.markerBikerLocation,
    this.markerUserLocation,
  });

  @override
  State<OrderChangeStatus> createState() => _OrderChangeStatusState();
}

class _OrderChangeStatusState extends State<OrderChangeStatus> {
  PanelController panelController = PanelController();
  //
  double zoom = 12.5;
  Set<Marker> markers = <Marker>{};
  List<LatLng> points = <LatLng>[];
  List<Polyline> polyline = <Polyline>[];
  // GoogleMapPolyline googleMapPolyline =
  //     GoogleMapPolyline(apiKey: AppConfig.kApiKey);
  List<LatLng> routes = <LatLng>[];
  StreamSubscription<Position>? positionStream;

  void getCurrentLocation(
    BitmapDescriptor markerBikerLocation,
    BitmapDescriptor markerUserLocation,
  ) async {
    positionStream =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
        ).listen((Position position) async {
          debugPrint("llll ${position.latitude} ${position.longitude}");
          sl<AuthBloc>().currentPosition = LatLng(
            position.latitude,
            position.longitude,
          );
          debugPrint(
            "llll2 ${sl<AuthBloc>().currentPosition.latitude} ${sl<AuthBloc>().currentPosition.longitude}",
          );
          setState(() {
            markers.clear();
            polyline.clear();
            markers.add(
              Marker(
                markerId: const MarkerId("biker"),
                position: LatLng(
                  sl<AuthBloc>().currentPosition.latitude,
                  sl<AuthBloc>().currentPosition.longitude,
                ),
                icon: markerBikerLocation,
                flat: true,
              ),
            );
            markers.add(
              Marker(
                markerId: const MarkerId("user"),
                position: LatLng(
                  sl<HomeBloc>().orderDetails.location!.latitude!,
                  sl<HomeBloc>().orderDetails.location!.longitude!,
                ),
                icon: markerUserLocation,
                flat: true,
              ),
            );

            polyline.add(
              Polyline(
                polylineId: PolylineId('route'),
                points: routes,
                patterns: <PatternItem>[PatternItem.dot],
                width: 4,
                color: KColors.of(context).textSecondary,
                startCap: Cap.roundCap,
              ),
            );
          });

          if (sl<HomeBloc>().orderStep == 0) {
            debugPrint("on the way");
            sl<HomeBloc>().socketService
                .emit("biker:location-changes", <String, Object?>{
                  "order": sl<HomeBloc>().orderDetails.sId,
                  "latitude": sl<AuthBloc>().currentPosition.latitude,
                  "longitude": sl<AuthBloc>().currentPosition.longitude,
                  "streetName": "dataValue",
                  "subAdministrativeArea": "dataValue",
                });
          } else if (sl<HomeBloc>().orderStep == 1) {
            debugPrint("Arrived");
            positionStream?.cancel();
          }
        });
  }

  @override
  void initState() {
    super.initState();
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

  Future<dynamic> onMapCreated(GoogleMapController mapController) async {}

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final double screenHeight = MediaQuery.sizeOf(context).height;
    // Tall enough closed that the swipe for the next step is always on screen.
    final double minPanelHeight = math.min(
      KSwipeAction.height * 6 + MediaQuery.paddingOf(context).bottom,
      screenHeight * .75,
    );
    return Scaffold(
      backgroundColor: c.background,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) {
          if (state is BikerOrderSuccess) {
            getCurrentLocation(
              state.markerBikerLocation,
              state.markerUserLocation,
            );
          } else if (state is BikerCompleteOrderSuccess) {
            AlertHelper.ratingDialog(context, state.orderId);
          } else if (state is BikerCancelOrderSuccess) {
            positionStream?.cancel();
            showSnackBar(
              buildContext: context,
              message: translate(AppStrings.cancelOrderSuccess),
            );
            pop(context);
          } else if (state is BikerCancelOrderFailed) {
            showSnackBar(buildContext: context, message: state.error);
          } else if (state is BikerOnTheWayOrderFailed) {
            showSnackBar(buildContext: context, message: state.error);
          } else if (state is BikerArrivedOrderFailed) {
            showSnackBar(buildContext: context, message: state.error);
          } else if (state is BikerOnWashingOrderFailed) {
            showSnackBar(buildContext: context, message: state.error);
          } else if (state is BikerCompleteOrderFailed) {
            showSnackBar(buildContext: context, message: state.error);
          }
        },
        // The panel's parts listen for their own states.
        buildWhen: (HomeState previous, HomeState current) =>
            current is BikerOrderLoading ||
            current is BikerOrderSuccess ||
            current is BikerOrderFailed,
        builder: (BuildContext context, HomeState state) {
          if (state is BikerOrderLoading) {
            return const KLoadingState();
          } else if (state is! BikerOrderFailed) {
            return SlidingUpPanel(
              controller: panelController,
              maxHeight: math.max(screenHeight * .60, minPanelHeight),
              minHeight: minPanelHeight,
              color: c.surface,
              panelBuilder: (ScrollController scrollController) =>
                  StatusOrderBottomSheet(
                    order: widget.order,
                    index: widget.index ?? -1,
                    scrollController: scrollController,
                  ),
              body: _mapbody(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(KRadius.sheet),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: c.background,
              appBar: const GlassAppBar(),
              body: KErrorState(
                message: translate('defaultError'),
                onRetry: _handleOrder,
              ),
            );
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(KSpace.l),
            child: _bikerDetailsHeader(context),
          ),
        ),
      ],
    );
  }

  Row _bikerDetailsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            pushPage(context, const ProfileScreen());
          },
          child: HomeAvatar(
            imageUrl: sl<ProfileBloc>().profile.imageLink,
            name: sl<ProfileBloc>().profile.userName,
            size: KSpace.tapTarget,
          ),
        ),
        const BikerStatusSwitchWidget(),
        GlassIconButton(
          icon: Icons.close,
          sfSymbol: 'xmark',
          color: KColors.of(context).brand,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () {
            positionStream?.cancel();
            pop(context);
          },
        ),
      ],
    );
  }
}
