import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

class InformationSubscription extends StatelessWidget {
  final Subscription subscription;

  const InformationSubscription({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    final planColor = Color(int.parse("0xFF${subscription.plan!.color!}"));
    final washesPercentage =
        subscription.remainingWashes! / subscription.washesCount!;

    return Container(
      // padding: EdgeInsets.all(20.w),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16.r),
      //   border: Border.all(color: ColorManager.black.withOpacity(0.3)),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Name
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: planColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              subscription.plan!.type!.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Remaining Washes
          Text(
            translate(AppStrings.remainingWashes),
            style: TextStyle(
              color: ColorManager.black.withOpacity(0.6),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                '${subscription.remainingWashes}',
                style: TextStyle(
                  color: ColorManager.black,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / ${subscription.washesCount}',
                style: TextStyle(
                  color: ColorManager.black.withOpacity(0.5),
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Progress Bar
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: ColorManager.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: washesPercentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: planColor,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Expiry Date
          Text(
            translate(AppStrings.expiryDate),
            style: TextStyle(
              color: ColorManager.black.withOpacity(0.6),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            AppDateFormatter.allDate(
              DateTime.parse(subscription.expiryDate!),
              Localizations.localeOf(context).languageCode == 'en'
                  ? 'en_us'
                  : 'en_us',
            ),
            style: TextStyle(
              color: ColorManager.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
