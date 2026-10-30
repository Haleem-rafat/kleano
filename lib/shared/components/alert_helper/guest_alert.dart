import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/utilties/navigator.dart';

class GuestAlert extends StatelessWidget {
  const GuestAlert({super.key});

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
              padding: EdgeInsets.fromLTRB(
                AppPadding.p20.w,
                AppPadding.p18.h,
                AppPadding.p20.w,
                AppPadding.p10.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(child: SvgPicture.asset(AssetsManager.guest)),
                  AppPadding.p16.ph,
                  Text(
                    translate(AppStrings.yourNotRegisteredYet),
                    style: AppStyles.title16Regular
                        .copyWith(color: ColorManager.darkGrey),
                    textAlign: TextAlign.center,
                  ),
                  AppPadding.p24.ph,
                  ButtonsShared(
                    onPressed: () {
                      popALlAndPushPage(
                          context,
                          ChooseRegisterView(
                          ));
                    },
                    text: translate(AppStrings.signUpNow),
                    width: 222,
                    height: 50.h,
                    colorText: ColorManager.white,
                    colorButton: ColorManager.primary,
                    colorBorder: ColorManager.primary,
                    showShadow: false,
                  ),
                  16.verticalSpace,
                  GestureDetector(
                    onTap: () {
                      pop(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.cancel),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: ColorManager.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}
