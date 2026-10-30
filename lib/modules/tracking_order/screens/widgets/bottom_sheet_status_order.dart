import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/biker_info.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/events_stepper.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/name_and_time_events_list.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';

class StatusOrderBottomSheet extends StatefulWidget {
  final PanelController? panelController;
  final AcceptedOrderByBikerModel? acceptedOrderByBikerModel;
  final OrderModel? orderModel;
  const StatusOrderBottomSheet({
    super.key,
    this.panelController,
    this.acceptedOrderByBikerModel,
    this.orderModel,
  });

  @override
  State<StatusOrderBottomSheet> createState() => _StatusOrderBottomSheetState();
}

class _StatusOrderBottomSheetState extends State<StatusOrderBottomSheet> {
  void togglePanle() {
    widget.panelController!.isPanelOpen ? widget.panelController!.close() : widget.panelController!.open();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: togglePanle,
          child: Container(
            margin: EdgeInsets.only(top: AppPadding.p16.h),
            width: 36.w,
            height: 5.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.w), color: ColorManager.thirdColor400),
          ),
        ),
        BlocConsumer<SocketBloc, SocketState>(
          listener: (BuildContext context, SocketState socketState) {
          if (socketState is SocketIoReceivedAnUpdateState) {
            if (socketState.baseModelSocketStatus != null) {
              if (widget.acceptedOrderByBikerModel != null) {
                widget.acceptedOrderByBikerModel!.status = socketState.baseModelSocketStatus!.status;
                widget.orderModel!.status = socketState.baseModelSocketStatus!.status;
              } else if (widget.orderModel != null) {
                widget.orderModel!.status = socketState.baseModelSocketStatus!.status;
              }
            } else {
              widget.acceptedOrderByBikerModel!.status = widget.acceptedOrderByBikerModel!.status;
            } 
          } else if (socketState is ReceivedOrderCompletedSuccess) {
            AlertHelper.userRatingOrder(context, socketState.orderId);
          }
        }, builder: (context, socketState) {
          if (socketState is SocketIoReceivedAnUpdateState) {
            return Column(
              children: <Widget>[
                BikerInformation(
                  biker: widget.acceptedOrderByBikerModel != null ? widget.acceptedOrderByBikerModel!.biker! : widget.orderModel!.biker!,
                  status: widget.acceptedOrderByBikerModel != null ? widget.acceptedOrderByBikerModel!.status! : widget.orderModel!.status!,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 47.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      EventsStepper(
                        status: widget.orderModel != null ? widget.orderModel!.status! : widget.orderModel!.status,
                      ),
                      AppSize.s6.pw,
                      NameAndTimeEventsList(
                        orderModel: widget.orderModel,
                      )
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              BikerInformation(
                biker: widget.acceptedOrderByBikerModel != null ? widget.acceptedOrderByBikerModel!.biker! : widget.orderModel!.biker!,
                status: widget.acceptedOrderByBikerModel != null ? widget.acceptedOrderByBikerModel!.status! : widget.orderModel!.status!,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 47.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    EventsStepper(
                      status: widget.orderModel != null ? widget.orderModel!.status! : null,
                    ),
                    AppSize.s6.pw,
                    NameAndTimeEventsList(
                      orderModel: widget.orderModel,
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
