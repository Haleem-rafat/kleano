import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class TextFormShared extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final ValueChanged? onChanged;
  final validator;
  final String? errorText;
  final bool autoFocus;
  final List<TextInputFormatter>? textInputFormat;
  final int maxLine;
  final Widget? prefix;
  final bool? obscure;
  final String? initialValue;
  final Function(String)? onSubmit;
  final FocusNode? focusNode;
  final double radius;
  final bool enabled;

  const TextFormShared({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.textInputFormat,
    this.validator,
    this.onSubmit,
    this.textInputAction,
    this.autoFocus = false,
    this.errorText,
    this.prefixIcon,
    this.textInputType,
    this.radius = 14,
    this.initialValue,
    this.maxLine = 1,
    this.obscure = false,
    this.prefix,
    this.suffixIcon,
    this.focusNode,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        focusNode: focusNode,
        textDirection: TextDirection.ltr,
        initialValue: initialValue,
        autofocus: autoFocus,
        controller: controller,
        keyboardType: textInputType,
        textInputAction: textInputAction,
        validator: validator,
        cursorColor: ColorManager.primary,
        onChanged: onChanged,
        onFieldSubmitted: onSubmit,
        inputFormatters: textInputFormat,
        maxLines: maxLine,
        obscureText: obscure!,
        enabled: enabled,
        style: AppStyles.titleGray16Regular.copyWith(
          color: ColorManager.darkGrey,
        ),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: AppPadding.p16.w, vertical: AppPadding.p18.h),
            hintText: hintText,
            hintStyle: AppStyles.titleGray16Regular.copyWith(
              color: ColorManager.medGray,
            ),
            border: OutlineInputBorder(
                gapPadding: 0,
                borderSide: BorderSide(
                  color: ColorManager.lightGray,
                ),
                borderRadius: BorderRadius.circular(radius.r)),
            errorBorder: OutlineInputBorder(
                gapPadding: 0,
                borderSide: const BorderSide(
                  color: ColorManager.red,
                ),
                borderRadius: BorderRadius.circular(radius.r)),
            fillColor: ColorManager.white,
            prefix: prefix,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            focusedBorder: OutlineInputBorder(
                gapPadding: 0,
                borderSide: BorderSide(
                  color: ColorManager.secondary,
                ),
                borderRadius: BorderRadius.circular(14.r)),
            enabledBorder: OutlineInputBorder(
                gapPadding: 0,
                borderSide: BorderSide(
                  color: ColorManager.lightGray,
                ),
                borderRadius: BorderRadius.circular(14.r))));
  }
}
