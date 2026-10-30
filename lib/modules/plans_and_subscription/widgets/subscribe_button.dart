import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class SubscribeButton extends StatefulWidget {
  final bool userHaveAPlan;
  final String planId;
  final String planType;
  final double planPrice;
  final bool isSubscribed, comeformBooking;
  final String createdAt;
  const SubscribeButton({
    super.key,
    required this.userHaveAPlan,
    required this.createdAt,
    required this.planId,
    required this.planType,
    required this.planPrice,
    required this.isSubscribed,
    this.comeformBooking = false,
  });

  @override
  State<SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  @override
  Widget build(BuildContext context) {
    return !widget.comeformBooking
        ? GestureDetector(
            onTap: () {
              AppShared.token.isNotEmpty
                  ? !widget.userHaveAPlan
                      ? AlertHelper.createSubscription(
                          createdAt: widget.createdAt,
                          context: context,
                          planType: widget.planType,
                          price: widget.planPrice,
                          planId: widget.planId,
                        )
                      : showSnackBar(
                          buildContext: context,
                          message:
                              translate(AppStrings.youHaveAlreadySubscribed))
                  : AlertHelper.guestAlert(context);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 26.h,
              width: 77.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: widget.userHaveAPlan
                          ? ColorManager.darkGrey
                          : ColorManager.primary),
                  color: widget.userHaveAPlan
                      ? ColorManager.white
                      : ColorManager.primary),
              child: Center(
                child: Text(
                  widget.isSubscribed
                      ? translate(AppStrings.subscribed)
                      : "Checkout",
                  style: AppStyles.title16Bold.copyWith(
                    color: widget.userHaveAPlan
                        ? ColorManager.darkGrey
                        : ColorManager.white,
                    fontSize: 10.sp,
                    height: 13.h / 10.sp,
                  ),
                ),
              ),
            ),
          )
        : SizedBox();
  }
}
