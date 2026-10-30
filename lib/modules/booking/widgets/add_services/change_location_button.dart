import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class ButtonChangeLocation extends StatelessWidget {
  const ButtonChangeLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pop(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 26.h,
        width: 98.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: ColorManager.darkGrey),
            color: Colors.transparent),
        child: Center(
          child: Text(
            translate(AppStrings.changeLocation),
            style: AppStyles.title16Bold.copyWith(
              color: ColorManager.darkGrey,
              fontSize: 10.sp,
              height: 13.h / 10.sp,
            ),
          ),
        ),
      ),
    );
  }
}
