import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_indicator.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/on_boarding/on_boarding_model.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/utilties/navigator.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

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
    currentIndex = 0;
    _controller = PageController();
    onBoardingModel = BoardingModel.listOnBoarding;
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
                      height: 1.sh,
                      width: 1.sw,
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                    ));
              }).toList(),
            ),
            Positioned(
              top: 0.h,
              right: 0.w,
              child: SvgPicture.asset(
                AssetsManager.shapCircleRight,
                colorFilter: ColorFilter.mode(ColorManager.primary, BlendMode.srcIn),
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
                top: 503.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IgnorePointer(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
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
                            EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                        child: SizedBox(
                          child: Text(
                            onBoardingModel[currentIndex].body,
                            style: AppStyles.title18Regular
                                .copyWith(color: ColorManager.white),
                          ),
                        ),
                      ),
                    ),
                    32.verticalSpace,
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
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
                            innerPadding: AppPadding.p8.w,
                            selectedColor: ColorManager.white,
                            unselectedColor:
                                ColorManager.white.withValues(alpha: .50),
                          )),
                    ),
                    78.verticalSpace,
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                      child: Hero(
                        tag: 'buttons',
                        child: ButtonsShared(
                          onPressed: () {
                            if (currentIndex == 2) {
                              popALlAndPushPage(context, ChooseRegisterView());
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
                  left: AppMargin.m30.w,
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Localization button
                      GestureDetector(
                        onTap: () {
                          final currentLocale =
                              Localizations.localeOf(context).languageCode;
                          final newLocale = currentLocale == 'en' ? 'ar' : 'en';
                          changeLocale(context, newLocale);
                          setState(() {
                            AppShared.lang = newLocale;
                          });
                          popALlAndPushPage(context, const OnboardScreen());
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: ColorManager.white, width: 1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            Localizations.localeOf(context).languageCode == 'en'
                                ? AppConstants.arabic
                                : AppConstants.english,
                            style: AppStyles.titleWhite16Bold.copyWith(
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Skip button
                      GestureDetector(
                        onTap: () {
                          pushPage(context, ChooseRegisterView());
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          translate(AppStrings.skip),
                          style: AppStyles.titleWhite16Bold.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: ColorManager.white,
                          ),
                        ),
                      ),
                    ],
                  ))
          ],
        ),
      ),
    );
  }
}
