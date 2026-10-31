import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/shared/components/text-form-shared.dart';

class ListTileTextForm extends StatelessWidget {
  final String title;
  final String hintText;
  final TextInputType textInputType;
  final Widget? prefix;
  final TextEditingController? controller;
  final String? Function(String? value) validator;
  final String? initialValue;
  final List<TextInputFormatter>? textInputFormatter;
  final ValueChanged? onChange;
  final bool obscure;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final VoidCallback? onEditingComplete;

  const ListTileTextForm({
    super.key,
    required this.title,
    required this.hintText,
    required this.textInputType,
    this.prefix,
    this.controller,
    required this.validator,
    this.textInputFormatter,
    this.initialValue,
    this.onChange,
    this.textInputAction,
    this.autofillHints,
    this.onEditingComplete,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
        child: Text(
          title,
          style: AppStyles.title16Regular.copyWith(color: ColorManager.darkGrey),
        ),
      ),
      subtitle: Column(
        children: <Widget>[
          const SizedBox(
            height: AppSize.s8,
          ),
          TextFormShared(
            initialValue: initialValue,
            validator: validator,
            textInputType: textInputType,
            controller: controller,
            hintText: hintText,
            prefixIcon: prefix,
            textInputFormat: textInputFormatter,
            onChanged: onChange,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            onEditingComplete: onEditingComplete,
            obscure: obscure,
          ),
        ],
      ),
    );
  }
}
