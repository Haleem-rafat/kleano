import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/modules/tracking_order/screens/tracking_order_main_screen.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class ButtonTrackingOrder extends StatefulWidget {
  final OrderModel orderModel;
  const ButtonTrackingOrder({
    super.key,
    required this.orderModel,
  });

  @override
  State<ButtonTrackingOrder> createState() => _ButtonTrackingOrderState();
}

class _ButtonTrackingOrderState extends State<ButtonTrackingOrder> {
  GeneralSingleton generalSingleton = GeneralSingleton();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.orderModel.status == AppConstants.active ||
            widget.orderModel.status == AppConstants.waitingForBikerByAdmin) {
          showSnackBar(
              buildContext: context,
              message: translate(AppStrings.connectingYouToNearestBiker));
        } else {
          generalSingleton.orderId = widget.orderModel.sId;
          generalSingleton.timeOnTheWay = '';
          generalSingleton.timeArrived = '';
          generalSingleton.timeWashing = '';
          generalSingleton.timeComplete = '';
          BlocProvider.of<SocketBloc>(context).add(OpenSocketIo());
          pushPage(
              context,
              TrackingOrderMainScreen(
                orderModel: widget.orderModel,
              ));
        }
      },
      behavior: HitTestBehavior.opaque,
      child: ButtonRowShared(
        buttonText: translate(AppStrings.trackYourWash),
      ),
    );
  }
}
