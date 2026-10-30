import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/Auth/screens/log_in_screen.dart';
import 'package:thewasher/modules/Auth/screens/sign_up_screen.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/utilties/navigator.dart';

class ChooseRegisterView extends StatefulWidget {
  // bool comeFromMain;
  const ChooseRegisterView({super.key,});

  @override
  State<ChooseRegisterView> createState() => _ChooseRegisterViewState();
}

class _ChooseRegisterViewState extends State<ChooseRegisterView> {
  Future<void> checkFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('FirstTime')) {
      prefs.setBool('FirstTime', true);
    }
  }

  @override
  void initState() {
    checkFirstSeen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Image.asset(
              AssetsManager.onBoardingFour,
              height: 1.sh,
              width: 1.sw,
              gaplessPlayback: true,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 0.h,
              right: 0.w,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  ColorManager.primary,
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(
                  AssetsManager.shapCircleRight,
                ),
              ),
            ),
            Positioned(
              top: 0.h,
              left: 0.w,
              child: SvgPicture.asset(
                AssetsManager.shapCircleLeft,
              ),
            ),
            Positioned(
                top: 112.h,
                right: 100.w,
                left: 100.w,
                child: SvgPicture.asset(
                  AssetsManager.logoWhite,
                )),
            Positioned(
              bottom: AppPadding.p45.h,
              left: AppPadding.p24.w,
              right: AppPadding.p24.w,
              child: Column(
                children: <Widget>[
                  Hero(
                    tag: 'buttons',
                    child: ButtonsShared(
                      onPressed: () {
                        pushPage(context, const SignUpScreen());
                      },
                      text: translate(AppStrings.signUp),
                    ),
                  ),
                  AppPadding.p24.ph,
                  ButtonsShared(
                    onPressed: () {
                      pushPage(context, const LogInScreen());
                    },
                    text: translate(AppStrings.login),
                    colorBorder: ColorManager.secondary,
                    colorButton: ColorManager.secondary.withValues(alpha: .050),
                    colorText: ColorManager.white,
                    showShadow: false,
                  ),
                  AppPadding.p24.ph,
                  GestureDetector(
                    onTap: () {
                      AppShared.setToken("");
                      isGuestUser = true;
                      popALlAndPushPage(
                          context,
                          MainNavigationScreen(
                            selectedIndex: 0,
                          ));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.continueAsAGuest),
                      style: AppStyles.title16Medium.copyWith(
                          color: ColorManager.white,
                          decoration: TextDecoration.underline,
                          decorationColor: ColorManager.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
