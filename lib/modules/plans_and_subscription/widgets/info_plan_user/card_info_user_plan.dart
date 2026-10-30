import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/info_plan_user/info_subscription.dart';

class CardInfoUserPlan extends StatelessWidget {
  final Subscription subscription;
  const CardInfoUserPlan({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            bottom: AppMargin.m16.h,
            left: AppMargin.m24.w,
            right: AppMargin.m24.w),
        padding: EdgeInsets.only(
            top: AppPadding.p22.h,
            bottom: AppPadding.p21.h,
            left: AppPadding.p18.w,
            right: AppPadding.p18.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.s12.r),
          color: ColorManager.backGround,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: ColorManager.black.withOpacity(.05),
                blurRadius: 3.r,
                offset: const Offset(0, 6))
          ],
        ),
        child: InformationSubscription(
          subscription: subscription,
        ));
  }
}
