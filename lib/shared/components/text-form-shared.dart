import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';

class TextFormShared extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final ValueChanged? onChanged;
  final validator;
  final String? errorText;
  final bool autoFocus;
  final List<TextInputFormatter>? textInputFormat;
  final int maxLine;
  final Widget? prefix;
  final bool obscure;
  final String? initialValue;
  final Iterable<String>? autofillHints;
  final VoidCallback? onEditingComplete;

  const TextFormShared({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.textInputFormat,
    this.validator,
    this.textInputAction,
    this.autoFocus = false,
    this.errorText,
    this.prefixIcon,
    this.textInputType,
    this.initialValue,
    this.autofillHints,
    this.onEditingComplete,
    this.maxLine = 1,
    required this.obscure,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        initialValue: initialValue,
        autofocus: autoFocus,
        controller: controller,
        keyboardType: textInputType,
        textInputAction: textInputAction,
        validator: validator,
        cursorColor: ColorManager.primary,
        onChanged: onChanged,
        inputFormatters: textInputFormat,
        maxLines: maxLine,
        obscureText: obscure,
        style: AppStyles.titleGray16Regular,
        autofillHints: autofillHints,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: AppPadding.p16.w, vertical: AppPadding.p18.h),
            hintText: hintText,
            hintStyle: AppStyles.titleGray16Regular,
            border: OutlineInputBorder(
                gapPadding: 0,
                borderSide: BorderSide(
                  color: ColorManager.medGray,
                ),
                borderRadius: BorderRadius.circular(14.r)),
            errorBorder: OutlineInputBorder(
                gapPadding: 0,
                borderSide: const BorderSide(
                  color: ColorManager.red,
                ),
                borderRadius: BorderRadius.circular(14.r)),
            fillColor: ColorManager.white,
            // suffixIcon: suffix,
            prefix: prefix,
            prefixIcon: prefixIcon,
            focusedBorder: OutlineInputBorder(
                gapPadding: 0,
                borderSide: BorderSide(
                  color: ColorManager.secondary,
                ),
                borderRadius: BorderRadius.circular(14.r)),
            enabledBorder: OutlineInputBorder(
                gapPadding: 0,
                borderSide: BorderSide(
                  color: ColorManager.medGray,
                ),
                borderRadius: BorderRadius.circular(14.r))));
  }
}
