import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_indicator.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/modules/on_boarding/on_boarding_model.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  static late int currentIndex;
  late PageController _controller;
  late List<BoardingModel> onBoardingModel;

  @override
  void initState() {
    super.initState();
    onBoardingModel = BoardingModel.listOnBoarding;
    currentIndex = 0;
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _controller,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: onBoardingModel.map((e) {
                return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      e.image,
                      height: AppSize.s812.h,
                      width: AppSize.s375.w,
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                    ));
              }).toList(),
            ),
            Positioned(
              top: 0.h,
              right: 0.w,
              child: SvgPicture.asset(
                ImageAssets.shapeCircleRight,
                color: ColorManager.primary,
              ),
            ),
            Positioned(
              top: 0.h,
              left: 0.w,
              child: SvgPicture.asset(
                ImageAssets.shapeCircleLeft,
              ),
            ),
            Positioned(
                top: 503.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IgnorePointer(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 5000),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            onBoardingModel[currentIndex].title,
                            style: AppStyles.titleWhite16Bold.copyWith(
                                fontSize: 32.sp, height: 43.h / 32.sp),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
                        child: SizedBox(
                          child: Text(
                            onBoardingModel[currentIndex].body,
                            style: AppStyles.headlines24Regular
                                .copyWith(color: ColorManager.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.s60.h),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
                      child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 700),
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: AppIndicator(
                            currentIndex: currentIndex,
                            length: onBoardingModel.length,
                            height: 9,
                            width: 9,
                            selectedWidth: AppSize.s47.w,
                            innerPadding: AppPadding.p10.w,
                            selectedColor: ColorManager.white,
                            unselectedColor:
                                ColorManager.white.withOpacity(.50),
                          )),
                    ),
                    SizedBox(height: AppSize.s54.h),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                      child: Hero(
                        tag: 'buttons',
                        child: ButtonsShared(
                          borderRadius: 8,
                          textStyle: AppStyles.title16Bold,
                          onPressed: () {
                            if (currentIndex == 2) {
                              popALlAndPushPage(context, LogInScreen());
                            } else {
                              setState(() {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              });
                            }
                          },
                          text: currentIndex == 2
                              ? translate(AppStrings.getStarted)
                              : translate(AppStrings.next),
                        ),
                      ),
                    ),
                  ],
                )),
            if (currentIndex != onBoardingModel.length - 1)
              Positioned(
                  top: AppMargin.m50.h,
                  right: AppMargin.m30.w,
                  child: GestureDetector(
                    onTap: () {
                      popALlAndPushPage(context, LogInScreen());
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.skip),
                      style: AppStyles.titleWhite16Bold.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: ColorManager.white),
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}
