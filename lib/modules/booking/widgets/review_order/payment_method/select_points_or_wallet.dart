import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/widgets/review_order/payment_method/using_points.dart';

class SelectPaymentMethodsPointsOrWallet extends StatelessWidget {
  final String orderId;
  final num points;
  const SelectPaymentMethodsPointsOrWallet({
    super.key,
    required this.orderId,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // AppPadding.p18.ph,
        // Text(
        //   translate(AppStrings.paymentMethod),
        //   style: AppStyles.title16Bold.copyWith(color: ColorManager.darkGrey),
        // ),
        // AppPadding.p8.ph,

        UsingPoints(
          orderId: orderId,
          points: points,
        )
      ],
    );
  }
}
