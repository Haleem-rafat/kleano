import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/my_booking/widgets/wash_section.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/rating_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class YourRating extends StatelessWidget {
  final String orderId;
  final double orderRating;
  const YourRating({
    super.key,
    required this.orderId,
    required this.orderRating,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingOrderBloc, BookingOrderState>(
      bloc: sl<BookingOrderBloc>(),
      builder: (BuildContext context, BookingOrderState state) {
        if (orderRating == 0.0) {
          return KButton(
            label: translate(AppStrings.rateWashNow),
            onPressed: () => AlertHelper.userRatingOrder(context, orderId),
          );
        }
        return WashSection(
          title: translate(AppStrings.yourRating),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: RatingBarShared(ratingCount: orderRating),
          ),
        );
      },
    );
  }
}
