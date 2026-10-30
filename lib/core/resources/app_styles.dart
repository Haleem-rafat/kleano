import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/fonts_manager.dart';

class AppStyles {
  static const SystemUiOverlayStyle lightStatusBarIconsStyle =
      SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle lightStatusBarIconsWithBlackColorStyle =
      SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    statusBarColor: ColorManager.black,
  );

  static const SystemUiOverlayStyle
      lightStatusBarIconsWithTransparentColorStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
  );

  static const SystemUiOverlayStyle darkStatusBarIconsStyle =
      SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle darkStatusBarIconsWithWhiteColorStyle =
      SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: ColorManager.white,
  );

  static const SystemUiOverlayStyle
      darkStatusBarIconsWithTransparentColorStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  );

  static const SystemUiOverlayStyle lightNavBarStyle = SystemUiOverlayStyle(
    systemNavigationBarColor: ColorManager.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle darkNavBarStyle = SystemUiOverlayStyle(
    systemNavigationBarColor: ColorManager.black,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const String fontFamily = 'Roboto';
  static const String fontOfferFamily = 'ScriptMT';
  //Poppins text styles
  //H1
  static final TextStyle headlinesWhite24Regular = TextStyle(
    fontWeight: FontWeightManager.regular,
    fontSize: FontSize.s24.sp,
    color: ColorManager.white,
    height: 32.h / 24.sp,
  );
  static final TextStyle headlines24Regular = TextStyle(
    // fontFamily: fontFamily,
    fontWeight: FontWeightManager.regular,
    fontSize: FontSize.s24.sp,
    height: 32.h / 24.sp,
  );
  static final TextStyle titleWhite16Bold = TextStyle(
    // fontFamily: fontFamily,
    fontWeight: FontWeightManager.bold,
    fontSize: FontSize.s16.sp,
    color: ColorManager.white,
    height: 21.h / 16.sp,
  );
  static final TextStyle title24Bold = TextStyle(
    // fontFamily: fontFamily,
    fontWeight: FontWeightManager.bold,
    fontSize: FontSize.s24.sp,
    height: 32.h / 24.sp,
  );
  static final TextStyle title16Bold = TextStyle(
    // fontFamily: fontFamily,
    fontWeight: FontWeightManager.bold,
    fontSize: FontSize.s16.sp,
    height: 21.h / 16.sp,
  );
  static final TextStyle title16Regular = TextStyle(
    // fontFamily: fontFamily,
    fontWeight: FontWeightManager.regular,
    fontSize: FontSize.s16.sp,
    height: 21.h / 16.sp,
  );
  static final TextStyle titleGray16Regular = TextStyle(
    // fontFamily: fontFamily,
    fontWeight: FontWeightManager.regular,
    fontSize: FontSize.s16.sp,
    color: ColorManager.black,
    height: 21.h / 16.sp,
  );
  static final TextStyle title18Regular = TextStyle(
    fontWeight: FontWeightManager.regular,
    fontSize: FontSize.s16.sp,
    height: 22.h / 18.sp,
  );
  static final TextStyle body14Medium = TextStyle(
    fontWeight: FontWeightManager.medium,
    fontSize: FontSize.s14.sp,
    height: 19.h / 14.sp,
  );
  static final TextStyle subtext14Regular = TextStyle(
    fontWeight: FontWeightManager.regular,
    fontSize: FontSize.s14.sp,
    height: 19.h / 14.sp,
  );
  static final TextStyle subtextGray14Regular = TextStyle(
    fontWeight: FontWeightManager.regular,
    fontSize: FontSize.s14.sp,
    color: ColorManager.medGray,
    height: 19.h / 14.sp,
  );
  static final TextStyle captionGray12Medium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeightManager.medium,
    fontSize: FontSize.s12.sp,
    color: ColorManager.medGray,
    height: 16.h / 12.sp,
  );
  static final TextStyle caption12Medium = TextStyle(
    fontWeight: FontWeightManager.medium,
    fontSize: FontSize.s12.sp,
    height: 16.h / 12.sp,
  );
  static final TextStyle caption12Regular = TextStyle(
    fontWeight: FontWeightManager.regular,
    fontSize: FontSize.s12.sp,
    height: 16.h / 12.sp,
  );
  static final TextStyle offerBigStyle = TextStyle(
    fontFamily: fontOfferFamily,
    fontWeight: FontWeightManager.bold,
    fontSize: FontSize.s20.sp,
    height: 18.h / 20.sp,
  );

  static final TextStyle offerSmallStyle = TextStyle(
    fontFamily: fontOfferFamily,
    fontWeight: FontWeightManager.bold,
    fontSize: FontSize.s15.sp,
    height: 15.h / 20.sp,
  );

  static final TextStyle title16Medium = TextStyle(
    // fontFamily: fontFamily,
    fontWeight: FontWeightManager.medium,
    fontSize: FontSize.s16.sp,
    height: 21.h / 16.sp,
  );
}
