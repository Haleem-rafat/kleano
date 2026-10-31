import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/modules/tracking_order/screens/tracking_order_main_screen.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

/// Secondary, not primary: a list can hold several orders on the way, and a
/// screen has one primary button at most.
class ButtonTrackingOrder extends StatelessWidget {
  final OrderModel orderModel;
  const ButtonTrackingOrder({super.key, required this.orderModel});

  void _onPressed(BuildContext context) {
    if (orderModel.status == AppConstants.active ||
        orderModel.status == AppConstants.waitingForBikerByAdmin ||
        orderModel.biker == null) {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.connectingYouToNearestBiker),
      );
    } else {
      final GeneralSingleton generalSingleton = GeneralSingleton();
      generalSingleton.orderId = orderModel.sId;
      generalSingleton.timeOnTheWay = '';
      generalSingleton.timeArrived = '';
      generalSingleton.timeWashing = '';
      generalSingleton.timeComplete = '';
      BlocProvider.of<SocketBloc>(context).add(OpenSocketIo());
      pushPage(context, TrackingOrderMainScreen(orderModel: orderModel));
    }
  }

  @override
  Widget build(BuildContext context) {
    return KButton(
      label: translate(AppStrings.trackYourWash),
      variant: KButtonVariant.secondary,
      onPressed: () => _onPressed(context),
    );
  }
}
