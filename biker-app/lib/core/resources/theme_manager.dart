import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/styles_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';

import 'color_manager.dart';
import 'fonts_manager.dart';

ThemeData getApplicationTheme(String lang) {
  return ThemeData(
    // main colors
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorManager.primary,
      primary: ColorManager.primary,
      surface: ColorManager.white,
    ),
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.primaryLight,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: ColorManager.medGray,
    splashColor: ColorManager.primaryLight,
    fontFamily: FontManager.getFontFamily(lang),
    scaffoldBackgroundColor: ColorManager.white,
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: AppStyles.titleWhite16Bold.copyWith(color: ColorManager.white, fontFamily: FontManager.getFontFamily(lang)),
    ),
    // button theme
    buttonTheme: ButtonThemeData(
        shape: const StadiumBorder(),
        disabledColor: ColorManager.white,
        buttonColor: ColorManager.primary,
        splashColor: ColorManager.primaryLight),

    // elevated button them
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            textStyle: getRegularStyle(color: ColorManager.white, fontSize: FontSize.s17),
            backgroundColor: ColorManager.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.s12)))),

    textTheme: TextTheme(
        displayLarge: getSemiBoldStyle(color: ColorManager.darkGrey, fontSize: FontSize.s16),
        headlineLarge: getSemiBoldStyle(color: ColorManager.darkGrey, fontSize: FontSize.s16),
        headlineMedium: getRegularStyle(color: ColorManager.darkGrey, fontSize: FontSize.s14),
        titleMedium: getMediumStyle(color: ColorManager.primary, fontSize: FontSize.s16),
        titleSmall: getRegularStyle(color: ColorManager.white, fontSize: FontSize.s16),
        // bodyLarge: getRegularStyle(color: ColorManager.grey1),
        // bodySmall: getRegularStyle(color: ColorManager.grey),
        // bodyMedium:
        //     getRegularStyle(color: ColorManager.grey2, fontSize: FontSize.s12),
        labelSmall: getBoldStyle(color: ColorManager.primary, fontSize: FontSize.s12)),

    // input decoration theme (text form field)
    inputDecorationTheme: InputDecorationTheme(
        // content padding
        contentPadding: const EdgeInsets.all(AppPadding.p8),
        // hint style
        hintStyle: getRegularStyle(color: ColorManager.medGray, fontSize: FontSize.s14),
        labelStyle: getMediumStyle(color: ColorManager.darkGrey, fontSize: FontSize.s14),
        errorStyle: getRegularStyle(color: ColorManager.red),

        // enabled border style
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.medGray, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),

        // focused border style
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.secondary, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),

        // error border style
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.red, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),
        // focused border style
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)))),
    // label style
  );
}
