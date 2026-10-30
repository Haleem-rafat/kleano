import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/utilties/navigator.dart';

class HeaderProfileGuestWidget extends StatelessWidget {
  const HeaderProfileGuestWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 180.h,
        width: 375.w,
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              height: 110.h,
              width: 375.w,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: ColorManager.black.withOpacity(.05),
                      blurRadius: 3.r,
                      offset: const Offset(0, 6))
                ],
                color: ColorManager.primary,
              ),
            ),
            Positioned(
                bottom: 35.h,
                left: 150.w,
                right: 150.w,
                child: Container(
                  height: 73.39.h,
                  width: 73.39.w,
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                      color: ColorManager.primaryLight2,
                      shape: BoxShape.circle),
                  child: Icon(
                    Icons.person,
                    color: ColorManager.secondary,
                    size: 50,
                  ),
                )),
            Positioned(
                bottom: 0.h,
                left: 125.w,
                right: 125.w,
                child: GestureDetector(
                  onTap: () {
                    popALlAndPushPage(context, ChooseRegisterView());
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 26.h,
                    decoration: BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: ColorManager.primary)),
                    child: Center(
                      child: Text(
                        translate(AppStrings.signUpNow),
                        textAlign: TextAlign.center,
                        style: AppStyles.title16Bold.copyWith(
                            color: ColorManager.primary, fontSize: 10.sp),
                      ),
                    ),
                  ),
                ))
          ],
        ));
  }
}
