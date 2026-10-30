import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
import 'package:thewasher/modules/tracking_order/screens/map_screen.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/app_bar_user_photo.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/bottom_sheet_status_order.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

class TrackingOrderMainScreen extends StatefulWidget {
  final AcceptedOrderByBikerModel? orderAcceptedModel;
  final OrderModel? orderModel;
  const TrackingOrderMainScreen({
    super.key,
    this.orderAcceptedModel,
    this.orderModel,
  });

  @override
  State<TrackingOrderMainScreen> createState() =>
      _TrackingOrderMainScreenState();
}

class _TrackingOrderMainScreenState extends State<TrackingOrderMainScreen> {
  final double _initFabHeight = 120.h;
  double fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 120.h;
  PanelController panelController = PanelController();
  GeneralSingleton generalSingleton = GeneralSingleton();
  @override
  void initState() {
    super.initState();
    fabHeight = _initFabHeight;
    generalSingleton.openTracking = true;
  }

  @override
  void dispose() {
    super.dispose();
    // sl<SocketBloc>()
    SocketBloc.socketIo!.close();
    SocketBloc.socketIo!.dispose();
    // panelController.close();
    generalSingleton.openTracking = false;
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .60;
    _panelHeightClosed = MediaQuery.of(context).size.height * .16;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: const AppBarUserPhoto(),
      ),
      body: Stack(
        children: <Widget>[
          SlidingUpPanel(
            controller: panelController,
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .3,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: ColorManager.black.withValues(alpha: .12),
                blurRadius: 2.r,
                offset: const Offset(0, 0),
              )
            ],
            panel: StatusOrderBottomSheet(
              panelController: panelController,
              acceptedOrderByBikerModel: widget.orderAcceptedModel,
              orderModel: widget.orderModel,
            ),
            body: MapScreen(
              bikerLocation: widget.orderAcceptedModel != null
                  ? LatLng(
                      widget.orderAcceptedModel!.biker!.latitude!,
                      widget.orderAcceptedModel!.biker!.longitude!,
                    )
                  : LatLng(
                      widget.orderModel!.biker!.latitude ?? 0.0,
                      widget.orderModel!.biker!.longitude ?? 0.0,
                    ),
              orderLocation: widget.orderModel!.location ??
                  sl.call<BookingOrderBloc>.call().orderLocation,
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.w),
                topRight: Radius.circular(20.w)),
            onPanelSlide: (double pos) => setState(() {
              fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),
        ],
      ),
    );
  }
}
