import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

class VechilceDetails extends StatelessWidget {
  final Vehicle vehicle;
  const VechilceDetails({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    int selectedColor = 0;
    selectedColor =
        colorList.indexWhere((element) => element.colorName == vehicle.color!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${vehicle.brand!} ${vehicle.model}',
          style: AppStyles.body14Medium.copyWith(color: ColorManager.black),
        ),
        Divider(
          endIndent: 88.w,
          color: ColorManager.divider,
          thickness: 1,
        ),
        Container(
          width: 326.w,
          height: 93.8.h,
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: vehicle.imageLink!.isEmpty
              ? Container(
                  width: 326.w,
                  height: 93.8.h,
                  decoration: BoxDecoration(
                    color: ColorManager.divider,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: ColorManager.darkGrey,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: ImageShared(
                    image: vehicle.imageLink!,
                    width: 326.w,
                    height: 93.8.h,
                  ),
                ),
        ),
        AppPadding.p8.ph,
        Row(
          children: <Widget>[
            Text(
              translate(AppStrings.plateNo),
              style: AppStyles.caption12Regular
                  .copyWith(color: ColorManager.black),
            ),
            6.pw,
            Text(
              vehicle.plateNumber!,
              style:
                  AppStyles.caption12Medium.copyWith(color: ColorManager.black),
            ),
          ],
        ),
        3.ph,
        Row(
          children: <Widget>[
            Text(
              translate(AppStrings.color),
              style: AppStyles.caption12Regular
                  .copyWith(color: ColorManager.black),
            ),
            6.pw,
            Container(
              height: 10.h,
              width: 10.w,
              decoration: BoxDecoration(
                  color: colorList[selectedColor].color ?? ColorManager.white,
                  border: selectedColor == 0
                      ? Border.all(color: ColorManager.black)
                      : null,
                  shape: BoxShape.circle),
            ),
            AppPadding.p4.pw,
            Text(
              vehicle.color!,
              style:
                  AppStyles.caption12Medium.copyWith(color: ColorManager.black),
            ),
          ],
        ),
      ],
    );
  }
}
