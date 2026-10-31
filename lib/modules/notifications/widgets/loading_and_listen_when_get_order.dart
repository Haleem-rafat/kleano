import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/my_booking/screens/wash_details.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/modules/tracking_order/screens/tracking_order_main_screen.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class LoadingAndListenWhenGetOrder extends StatelessWidget {
  // final bool completed;
  LoadingAndListenWhenGetOrder({
    super.key,
    // required this.completed,
  });
  final GeneralSingleton generalSingleton = GeneralSingleton();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingOrderBloc, BookingOrderState>(
      listener: (BuildContext context, BookingOrderState state) {
        if (state is OrderByIdSuccess) {
          // if (! generalSingleton.completed) {
          generalSingleton.orderId = state.orderModel.sId;
          generalSingleton.timeOnTheWay = '';
          generalSingleton.timeArrived = '';
          generalSingleton.timeWashing = '';
          generalSingleton.timeComplete = '';
          // Nothing to track until a biker has taken the order.
          if (state.orderModel.biker == null) {
            pushPage(
              context,
              WashDetailsScreen(orderId: state.orderModel.sId!),
            );
            return;
          }
          BlocProvider.of<SocketBloc>(context).add(OpenSocketIo());
          pushPage(
            context,
            TrackingOrderMainScreen(orderModel: state.orderModel),
          );
          // }
        }
      },
      builder: (BuildContext context, BookingOrderState state) {
        if (state is OrderByIdLoading) {
          return const KLoadingState();
        }
        return const SizedBox();
      },
    );
  }
}
