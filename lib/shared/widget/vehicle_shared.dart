import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class VehiclesCard extends StatelessWidget {
  final int index;
  final int selectedColor;
  final double? cardWidth;

  const VehiclesCard({
    super.key,
    required this.index,
    required this.selectedColor,
    this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final vehicle = sl<VehiclesBloc>().vehiclesList[index];
    final bool isSelected =
        sl<VehiclesBloc>().selectedVehicle.sId == vehicle.sId;

    return Container(
      width: cardWidth ?? 323.w,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isSelected ? ColorManager.secondary : Colors.transparent,
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black2.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Stack(
          children: [
            // Background Image
            vehicle.imageLink!.isEmpty
                ? Container(
                    color: ColorManager.black2.withValues(alpha: 0.1),
                    child: const Center(
                      child: Icon(Icons.directions_car,
                          size: 50, color: Colors.grey),
                    ),
                  )
                : ImageShared(
                    image: vehicle.imageLink!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),

            // Details
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${vehicle.brand} ${vehicle.model}",
                    style: AppStyles.body14Medium.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        translate(AppStrings.plateNo),
                        style: AppStyles.caption12Regular
                            .copyWith(color: Colors.white70),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        vehicle.plateNumber ?? '',
                        style: AppStyles.caption12Medium
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        translate(AppStrings.color),
                        style: AppStyles.caption12Regular
                            .copyWith(color: Colors.white70),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        height: 12.h,
                        width: 12.w,
                        decoration: BoxDecoration(
                          color: colorList[selectedColor].color,
                          border: selectedColor == 0
                              ? Border.all(color: Colors.white)
                              : null,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        vehicle.color ?? '',
                        style: AppStyles.caption12Medium
                            .copyWith(color: Colors.white),
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
