import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_stage_bar.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/biker_info.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/functions/check_step_data.dart';
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
    widget.panelController!.isPanelOpen
        ? widget.panelController!.close()
        : widget.panelController!.open();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: togglePanle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KSpace.xxxl,
              vertical: KSpace.m,
            ),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                color: KColors.of(context).textSecondary.withValues(alpha: 0.4),
              ),
              child: const SizedBox(width: 36, height: 5),
            ),
          ),
        ),
        Expanded(
          // Scrolling is off so drags keep moving the panel; on very short
          // screens the last rows clip instead of overflowing.
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: BlocConsumer<SocketBloc, SocketState>(
              listener: (BuildContext context, SocketState socketState) {
                if (socketState is SocketIoReceivedAnUpdateState) {
                  if (socketState.baseModelSocketStatus != null) {
                    if (widget.acceptedOrderByBikerModel != null) {
                      widget.acceptedOrderByBikerModel!.status =
                          socketState.baseModelSocketStatus!.status;
                      widget.orderModel!.status =
                          socketState.baseModelSocketStatus!.status;
                    } else if (widget.orderModel != null) {
                      widget.orderModel!.status =
                          socketState.baseModelSocketStatus!.status;
                    }
                  } else {
                    widget.acceptedOrderByBikerModel!.status =
                        widget.acceptedOrderByBikerModel!.status;
                  }
                } else if (socketState is ReceivedOrderCompletedSuccess) {
                  AlertHelper.userRatingOrder(context, socketState.orderId);
                }
              },
              builder: (BuildContext context, SocketState socketState) {
                final int step = getStepData(widget.orderModel!.status!).step;
                return Column(
                  children: <Widget>[
                    BikerInformation(
                      biker: widget.acceptedOrderByBikerModel != null
                          ? widget.acceptedOrderByBikerModel!.biker!
                          : widget.orderModel!.biker!,
                      status: widget.acceptedOrderByBikerModel != null
                          ? widget.acceptedOrderByBikerModel!.status!
                          : widget.orderModel!.status!,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KSpace.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          KStageBar(
                            step: step,
                            semanticLabel: getStepData(
                              widget.orderModel!.status!,
                            ).label,
                            stages: <String>[
                              translate(AppStrings.onTheWay),
                              translate(AppStrings.arrived),
                              translate(AppStrings.washing),
                              translate(AppStrings.completed),
                            ],
                          ),
                          const SizedBox(height: KSpace.xl),
                          NameAndTimeEventsList(
                            orderModel: widget.orderModel,
                            step: step,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
