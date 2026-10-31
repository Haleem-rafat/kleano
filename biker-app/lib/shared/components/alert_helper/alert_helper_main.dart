import 'package:flutter/material.dart';
import 'package:thewhsherbiker/shared/components/alert_helper/order_pop_up.dart';
import 'package:thewhsherbiker/shared/components/alert_helper/rating_dialog.dart';
import 'package:thewhsherbiker/shared/components/alert_helper/rating_success_dialog.dart';

class AlertHelper {
  static Future<Future<dynamic>> newOrder(BuildContext context) async =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const OrderPopUp(),
      );

  static Future<Future<dynamic>> ratingDialog(
    BuildContext context,
    String orderId,
  ) async => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => RatingOrderAlert(orderId: orderId),
  );

  static Future<Future<dynamic>> ratingSuccess(BuildContext context) async =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => RatingSuccessDialog(),
      );
}
