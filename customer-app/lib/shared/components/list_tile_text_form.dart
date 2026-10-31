import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/shared/components/text-form-shared.dart';

class ListTileTextForm extends StatelessWidget {
  final String title;
  final String hintText;
  final TextInputType textInputType;
  final Widget? prefix;
  final TextEditingController? controller;
  final String? Function(String? value)? validator;
  final String? initialValue;
  final List<TextInputFormatter>? textInputFormatter;
  final ValueChanged? onChange;
  final bool? isOptional;
  final bool? isPassword;
  final FocusNode? focusNode;

  const ListTileTextForm({
    super.key,
    required this.title,
    required this.hintText,
    required this.textInputType,
    this.prefix,
    this.focusNode,
    this.controller,
    this.validator,
    this.textInputFormatter,
    this.initialValue,
    this.onChange,
    this.isOptional,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style:
                  AppStyles.title16Regular.copyWith(color: ColorManager.black),
            ),
            if (isOptional == true)
              Text(
                '(${translate(AppStrings.optinal)})',
                style: AppStyles.subtext14Regular
                    .copyWith(color: ColorManager.black),
              ),
          ],
        ),
      ),
      subtitle: Column(
        children: <Widget>[
          AppSize.s8.ph,
          TextFormShared(
            focusNode: focusNode,
            initialValue: initialValue,
            validator: validator,
            textInputType: textInputType,
            controller: controller,
            hintText: hintText,
            prefixIcon: prefix,
            textInputFormat: textInputFormatter,
            onChanged: onChange,
            obscure: isPassword,
          ),
        ],
      ),
    );
  }
}
