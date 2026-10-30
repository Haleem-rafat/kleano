import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/screens/stepper_indecator.dart';

class StepperAppBar extends StatelessWidget {
  final VoidCallback onTap;
  final int index;
  const StepperAppBar({
    super.key,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    List<String> titles = [
      translate(AppStrings.services),
      translate(AppStrings.addOns),
      translate(AppStrings.vehicles),
      translate(AppStrings.location),
      translate(AppStrings.time),
    ];
    return StatefulBuilder(builder: (contex, setState) {
      return Column(
        children: [
          AppBarShared(
            titleAppBar: translate(AppStrings.bookAService),
            isTextOnly: false,
            isCenter: false,
            onTap: onTap,
          ),
          24.verticalSpace,
          CreationStepIndicator(
            step: index,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: AppPadding.p20.w,
              right: AppPadding.p20.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: titles.map((title) {
                return Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppStyles.caption12Medium
                      .copyWith(color: ColorManager.black),
                );
              }).toList(),
            ),
          ),
        ],
      );
      //  AppBar(
      //     automaticallyImplyLeading: false,
      //     centerTitle: false,
      //     title: Row(
      //       children: <Widget>[
      //         GestureDetector(
      //           onTap: onTap,
      //           behavior: HitTestBehavior.opaque,
      //           child: Icon(
      //             Icons.arrow_back_ios,
      //             size: 24.r,
      //             color: ColorManager.primary,
      //           ),
      //         ),
      //         SizedBox(
      //           width: 6.w,
      //         ),
      //         Text(
      //           translate(AppStrings.bookAService),
      //           style: AppStyles.title16Bold.copyWith(
      //             color: ColorManager.darkGrey,
      //           ),
      //         ),
      //       ],
      //     ),
      //     backgroundColor: ColorManager.white,
      //     elevation: 0,
      //     bottom: PreferredSize(
      //         preferredSize: Size(AppSize.s375, 100.h),
      //         child: Column(
      //           children: [
      //             CreationStepIndicator(
      //               step: index,
      //             ),
      //             Padding(
      //               padding: EdgeInsets.only(
      //                 left: AppPadding.p20.w,
      //                 right: AppPadding.p20.w,
      //               ),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: titles.map((title) {
      //                   return Text(
      //                     title,
      //                     textAlign: TextAlign.center,
      //                     style: AppStyles.caption12Medium
      //                         .copyWith(color: ColorManager.medGray),
      //                   );
      //                 }).toList(),
      //               ),
      //             ),
      //             SizedBox(
      //               height: AppPadding.p32.h,
      //             )
      //           ],
      //         )));
    });
  }
}
