import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
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
      builder: (context, state) {
        if (state is RateOrderSuccess) {
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (orderRating != 0.0) ...[
                Text(
                  translate(AppStrings.yourRating),
                  style: AppStyles.body14Medium.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
                Divider(
                  color: ColorManager.divider,
                  thickness: 1,
                  endIndent: 252.w,
                  indent: 0.w,
                  height: 15.h,
                ),
              ],

              AppPadding.p8.ph,
              RatingBarShared(
                ratingCount: orderRating,
              )
              // orderRating == 0.0
              //     ? GestureDetector(
              //         onTap: () {
              //           AlertHelper.userRatingOrder(context, orderId);
              //         },
              //         child: ButtonRowShared(
              //           buttonText: translate(AppStrings.rateWashNow),
              //         ),
              //       )
              //     : RatingBarShared(
              //         ratingCount: orderRating,
              //       )
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (orderRating != 0.0) ...[
              Text(
                translate(AppStrings.yourRating),
                style: AppStyles.body14Medium.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
              Divider(
                color: ColorManager.divider,
                thickness: 1,
                endIndent: 252.w,
                indent: 0.w,
                height: 15.h,
              ),
            ],
            AppPadding.p8.ph,
            orderRating == 0.0
                ? GestureDetector(
                    onTap: () {
                      AlertHelper.userRatingOrder(context, orderId);
                    },
                    child: ButtonRowShared(
                      buttonText: translate(AppStrings.rateWashNow),
                    ),
                  )
                : RatingBarShared(
                    ratingCount: orderRating,
                  )
          ],
        );
      },
      bloc: sl<BookingOrderBloc>(),
    );
  }
}
//  Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             AppStrings.yourRating,
//             style: AppStyles.body14Medium.copyWith(
//               color: ColorManager.darkGrey,
//             ),
//           ),
//           Divider(
//             color: ColorManager.divider,
//             thickness: 1,
//             endIndent: 252.w,
//             indent: 0.w,
//             height: 15.h,
//           ),
//           AppPadding.p8.ph,
//           orderRating == 0.0
//               ? GestureDetector(
//                   onTap: () {
//                     AlertHelper.userRatingOrder(context, orderId);
//                   },
//                   child: ButtonRowShared(
//                     buttonText: translate(AppStrings.rateWashNow),
//                   ),
//                 )
//               : RatingBarShared(
//                   ratingCount: orderRating,
//                 )
//         ],
//       ),
