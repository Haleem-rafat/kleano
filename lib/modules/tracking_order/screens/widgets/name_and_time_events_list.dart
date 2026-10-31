import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/order_status_names_and_time.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

class NameAndTimeEventsList extends StatelessWidget {
  final OrderModel? orderModel;
  final int step;
  NameAndTimeEventsList({super.key, this.orderModel, required this.step});
  final GeneralSingleton generalSingleton = GeneralSingleton();
  final String estimatedTimeLabel = translate(AppStrings.estimatedTime);

  List<String> bikerStatesName = <String>[
    translate(AppStrings.bikerOnTheWay),
    translate(AppStrings.bikerArrived),
    translate(AppStrings.startWashing),
    translate(AppStrings.yourCarIsCleanNow),
  ];
  @override
  Widget build(BuildContext context) {
    String getEstimatedTimeText(
      String time,
      String? timeValue, [
      String label = '',
      String unit = '',
    ]) {
      if (time.isNotEmpty) {
        return '$estimatedTimeLabel : $time';
      } else if (timeValue != null) {
        return '$estimatedTimeLabel : ${AppDateFormatter.dateToStringHHMMA(DateTime.parse(timeValue).toLocal())}';
      } else {
        return '';
      }
    }

    List<String> estimatedTimeBikerStates = <String>[
      getEstimatedTimeText(
        generalSingleton.timeOnTheWay,
        orderModel!.onTheWayAt,
      ),
      generalSingleton.timeArrived.isNotEmpty
          ? '${translate(AppStrings.estimatedTimeForWash)} : ${generalSingleton.timeArrived} ${translate(AppStrings.min)}'
          : orderModel != null && orderModel!.totalDuration != null
          ? '${translate(AppStrings.estimatedTimeForWash)} : ${orderModel!.totalDuration} ${translate(AppStrings.min)}'
          : '',
      getEstimatedTimeText(
        generalSingleton.timeWashing,
        orderModel!.onWashingAt,
      ),
      getEstimatedTimeText(generalSingleton.timeComplete, orderModel!.endTime),
    ];

    return OrderStutesNamesAndTime(
      step: step,
      bikerStatesName: bikerStatesName,
      estimatedTimeBikerStates: estimatedTimeBikerStates,
    );
  }
}
