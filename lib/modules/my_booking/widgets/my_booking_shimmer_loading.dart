import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/shared/components/shimmering/basic_container_shimmering.dart';

class MyBookingShimmerLoading extends StatelessWidget {
  final bool showTrackingButton;

  const MyBookingShimmerLoading({
    super.key,
    this.showTrackingButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // Show 3 shimmer cards
      itemBuilder: (_, index) {
        return _buildBookingCardShimmer();
      },
    );
  }

  Widget _buildBookingCardShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withValues(alpha: .05),
            blurRadius: 6.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppPadding.p16.w,
        AppPadding.p10.h,
        AppPadding.p16.w,
        AppPadding.p12.h,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: AppPadding.p28.w,
        vertical: 8.5.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Vehicle name shimmer
          BasicContainerShemmering(
            height: 14.h,
            width: 150.w,
            radius: 4,
          ),
          AppPadding.p8.ph,
          // Divider shimmer
          BasicContainerShemmering(
            height: 1.h,
            width: 200.w,
            radius: 1,
          ),
          AppPadding.p8.ph,
          // Vehicle card row shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Vehicle image shimmer
              BasicContainerShemmering(
                height: 52.h,
                width: 90.w,
                radius: 15,
              ),
              7.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Plate number row shimmer
                    Row(
                      children: [
                        BasicContainerShemmering(
                          height: 10.h,
                          width: 60.w,
                          radius: 4,
                        ),
                        6.pw,
                        BasicContainerShemmering(
                          height: 10.h,
                          width: 80.w,
                          radius: 4,
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    // Booking date shimmer
                    Row(
                      children: [
                        BasicContainerShemmering(
                          height: 10.h,
                          width: 70.w,
                          radius: 4,
                        ),
                        6.pw,
                        BasicContainerShemmering(
                          height: 10.h,
                          width: 100.w,
                          radius: 4,
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    // Color row shimmer
                    Row(
                      children: [
                        BasicContainerShemmering(
                          height: 10.h,
                          width: 40.w,
                          radius: 4,
                        ),
                        6.pw,
                        BasicContainerShemmering(
                          height: 10.h,
                          width: 10.w,
                          radius: 5,
                        ),
                        4.pw,
                        BasicContainerShemmering(
                          height: 10.h,
                          width: 50.w,
                          radius: 4,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppPadding.p8.ph,
          // Status and Payment badges row shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BasicContainerShemmering(
                height: 24.h,
                width: 100.w,
                radius: 12,
              ),
              BasicContainerShemmering(
                height: 24.h,
                width: 100.w,
                radius: 12,
              ),
            ],
          ),
          AppPadding.p8.ph,
          // View details button shimmer
          BasicContainerShemmering(
            height: 40.h,
            width: double.infinity,
            radius: 12,
          ),
          if (showTrackingButton) AppPadding.p8.ph,
          if (showTrackingButton)
            // Tracking button shimmer
            BasicContainerShemmering(
              height: 40.h,
              width: double.infinity,
              radius: 12,
            ),
        ],
      ),
    );
  }
}
