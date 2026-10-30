import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/shared/components/shimmering/basic_container_shimmering.dart';

class VehiclesShimmerLoading extends StatelessWidget {
  const VehiclesShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 23.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppPadding.p23.ph,
          // Title shimmer
          BasicContainerShemmering(
            height: 20.h,
            width: 150.w,
            radius: 8,
          ),
          AppPadding.p20.ph,
          // Vehicle cards shimmer
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.7,
            child: ListView.separated(
              itemCount: 3, // Show 3 shimmer cards
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return 7.ph;
              },
              itemBuilder: (context, int index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  child: _buildVehicleCardShimmer(),
                );
              },
            ),
          ),
          AppPadding.p10.ph,
          // Add button shimmer
          Center(
            child: BasicContainerShemmering(
              height: 48.h,
              width: 200.w,
              radius: 24,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVehicleCardShimmer() {
    return Container(
      width: 323.w,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black2.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Stack(
          children: [
            // Main card background shimmer
            BasicContainerShemmering(
              height: 180.h,
              width: 323.w,
              radius: 15,
            ),
            // Bottom details shimmer
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle name shimmer
                  BasicContainerShemmering(
                    height: 14.h,
                    width: 150.w,
                    radius: 4,
                  ),
                  SizedBox(height: 6.h),
                  // Plate number row shimmer
                  Row(
                    children: [
                      BasicContainerShemmering(
                        height: 12.h,
                        width: 60.w,
                        radius: 4,
                      ),
                      SizedBox(width: 6.w),
                      BasicContainerShemmering(
                        height: 12.h,
                        width: 80.w,
                        radius: 4,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Color row shimmer
                  Row(
                    children: [
                      BasicContainerShemmering(
                        height: 12.h,
                        width: 40.w,
                        radius: 4,
                      ),
                      SizedBox(width: 6.w),
                      // Color circle shimmer
                      BasicContainerShemmering(
                        height: 12.h,
                        width: 12.w,
                        radius: 6,
                      ),
                      SizedBox(width: 6.w),
                      BasicContainerShemmering(
                        height: 12.h,
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
      ),
    );
  }
}
