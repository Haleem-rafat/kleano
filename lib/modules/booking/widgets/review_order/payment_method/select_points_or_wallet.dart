import 'package:flutter/material.dart';
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
