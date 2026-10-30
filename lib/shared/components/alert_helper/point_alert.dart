import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/fonts_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class PointAlert extends StatelessWidget {
  const PointAlert({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      elevation: 0.6,
      backgroundColor: Colors.transparent,
      insetAnimationCurve: Curves.easeInOut,
      child: _buildChild(context),
    );
  }

  StatefulBuilder _buildChild(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, Function setState) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            decoration: BoxDecoration(
              color: ColorManager.white,
              border: Border.all(color: ColorManager.black),
            ),
            padding: EdgeInsets.fromLTRB(
              AppPadding.p20.w,
              AppPadding.p20.h,
              AppPadding.p20.w,
              AppPadding.p32.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Lottie.asset(
                  'assets/point.json',
                  repeat: true,
                  width: 88.w,
                  height: 88.h,
                ),
                AppPadding.p10.ph,
                Text(
                  translate(AppStrings.howPointsWorks),
                  style: AppStyles.title16Bold
                      .copyWith(color: ColorManager.secondary),
                ),
                AppPadding.p24.ph,
                Text(
                  translate(AppStrings.watchPointsGrow),
                  style: AppStyles.body14Medium.copyWith(
                      color: ColorManager.black,
                      fontWeight: FontWeightManager.bold),
                ),
                2.ph,
                SizedBox(
                  width: 274.w,
                  child: Text(
                    translate(AppStrings.certainNumberPoints),
                    textAlign: TextAlign.center,
                    style: AppStyles.subtext14Regular
                        .copyWith(color: ColorManager.medGray),
                  ),
                ),
                10.ph,
                Text(
                  translate(AppStrings.redeemPoints),
                  style: AppStyles.body14Medium.copyWith(
                      color: ColorManager.black,
                      fontWeight: FontWeightManager.bold),
                ),
                4.ph,
                SizedBox(
                  width: 274.w,
                  child: Text(
                    translate(AppStrings.certainAmountPoints),
                    textAlign: TextAlign.center,
                    style: AppStyles.subtext14Regular
                        .copyWith(color: ColorManager.medGray),
                  ),
                ),
                AppPadding.p30.ph,
                InkWell(
                  onTap: () {
                    pop(context);
                  },
                  child: Text(
                    translate(AppStrings.continueExplore),
                    style: AppStyles.title16Regular.copyWith(
                      color: ColorManager.primary,
                      fontWeight: FontWeightManager.medium,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
