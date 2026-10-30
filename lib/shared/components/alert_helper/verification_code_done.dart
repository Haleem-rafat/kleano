import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/layout/guest_flow.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

class VerificationCodeDone extends StatefulWidget {
  const VerificationCodeDone({super.key});

  @override
  State<VerificationCodeDone> createState() => _VerificationCodeDoneState();
}

class _VerificationCodeDoneState extends State<VerificationCodeDone> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                border: Border.all(color: ColorManager.darkGrey),
              ),
              padding: EdgeInsets.fromLTRB(36.w, 11.h, 36.w, 16.5.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // SvgPicture.asset(AssetsManager.checkCongratulations),
                  Lottie.asset(
                    'assets/success.json',
                    repeat: true,
                    width: 146.w,
                    height: 146.h,
                  ),
                  8.verticalSpace,
                  Text(
                    translate(AppStrings.congratulations),
                    style: AppStyles.title16Bold.copyWith(color: ColorManager.darkGrey),
                  ),
                  AppPadding.p12.ph,
                  SizedBox(
                    width: 292.w,
                    child: Text(
                      translate(AppStrings.yourAccountHaveBeenVerifiedSuccessfully),
                      textAlign: TextAlign.center,
                      style: AppStyles.subtext14Regular.copyWith(
                        color: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                  AppPadding.p20.ph,
                  GestureDetector(
                    onTap: () {
                      popALlAndPushPage(
                          context,
                          MainNavigationScreen(
                            selectedIndex: LoginFlow.selectedGuestIndex,
                          ));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.goToHome),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        decorationColor: ColorManager.primary,
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
