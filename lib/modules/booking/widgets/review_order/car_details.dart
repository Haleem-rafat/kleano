import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/shared/components/vehicle_card_data.dart';

class CarDetails extends StatelessWidget {
  // final Vehicle vehicle;
  final OrderModel order;
  const CarDetails({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          translate(AppStrings.carDetails),
          style:
              AppStyles.titleWhite16Bold.copyWith(color: ColorManager.black),
        ),
        // AppPadding.p14.ph,
        8.verticalSpace,
        Container(
          padding: EdgeInsets.fromLTRB(12.5.w, 16.h, 12.5.w, 16.h),
          decoration: BoxDecoration(
            color: ColorManager.white,
            border: Border.all(color: ColorManager.secondary),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: VechicleCardData(
            vehicle: order.vehicle!,
            isScheduled: order.isScheduled ?? false,
            bookingDate: DateTime.parse(order.createdAt!).toLocal(),
            washingDate: order.startTime != null
                ? DateTime.parse(order.startTime!).toLocal()
                : null,
          ),
        ),
      ],
    );
  }
}
