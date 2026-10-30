import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/resources/app_indicator.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class WaitForBikerBottomSheet extends StatefulWidget {
  const WaitForBikerBottomSheet({super.key});

  @override
  State<WaitForBikerBottomSheet> createState() => _WaitForBikerBottomSheetState();
}

class _WaitForBikerBottomSheetState extends State<WaitForBikerBottomSheet> {
  late Timer timer;
  late int i = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(milliseconds: 300),
      (_) {
        setState(() {
          if (i < 3) {
            i++;
          } else {
            i = 0;
          }
        });
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 475.48.h,
      width: 1.sw,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20.r), topLeft: Radius.circular(20.r)),
      ),
      child: Column(children: <Widget>[
        SizedBox(
          height: 20.h,
        ),
        GestureDetector(
          onTap: () => pop(context),
          child: Container(
            height: 8.h,
            width: 70.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              color: ColorManager.medGray,
            ),
          ),
        ),
        Lottie.asset(
          'assets/wait_biker.json',
          repeat: true,
          width: 282.w,
          height: 282.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppPadding.p32.h),
          child: Text(
            translate(AppStrings.connectingYouToNearestBiker),
            style: AppStyles.title16Bold.copyWith(
              color: ColorManager.darkGrey,
            ),
          ),
        ),
        AppIndicator(
          currentIndex: i,
          length: 4,
          height: 7,
          width: 70,
          selectedWidth: 70,
          innerPadding: 10.w,
          selectedColor: i == i + 1 ? ColorManager.primaryLight : ColorManager.primary,
          unselectedColor: ColorManager.divider,
        ),
      ]),
    );
  }
}
