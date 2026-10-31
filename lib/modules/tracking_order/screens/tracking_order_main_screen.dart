import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thewasher/core/design/tokens.dart';
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
  PanelController panelController = PanelController();
  GeneralSingleton generalSingleton = GeneralSingleton();
  @override
  void initState() {
    super.initState();
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
    final double screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarUserPhoto(),
      ),
      body: SlidingUpPanel(
        controller: panelController,
        maxHeight: screenHeight * .60,
        minHeight: screenHeight * .16,
        parallaxEnabled: true,
        parallaxOffset: .3,
        color: KColors.of(context).surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: KSpace.s,
          ),
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
          orderLocation:
              widget.orderModel!.location ??
              sl.call<BookingOrderBloc>.call().orderLocation,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KRadius.sheet),
        ),
      ),
    );
  }
}
