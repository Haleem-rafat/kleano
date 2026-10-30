import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/utilties/navigator.dart';

class GuestNotificationScreen extends StatelessWidget {
  const GuestNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarShared(
          titleAppBar: translate(AppStrings.notifications),
          isTextOnly: false,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(AssetsManager.notificationsEmpty),
            AppPadding.p24.ph,
            SizedBox(
              width: 232.w,
              child: Text(
                translate(AppStrings.yourNotRegisteredYetJoinUs),
                textAlign: TextAlign.center,
                style: AppStyles.title16Regular.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
            ),
            AppPadding.p24.ph,
            ButtonsShared(
                width: 164.w,
                onPressed: () {
                  popALlAndPushPage(
                      context,
                      ChooseRegisterView(
                      ));
                },
                text: translate(AppStrings.signUpNow))
          ],
        ),
      ),
    );
  }
}
