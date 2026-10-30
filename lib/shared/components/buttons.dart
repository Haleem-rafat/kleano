import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class ButtonsShared extends StatelessWidget {
  final VoidCallback onPressed;
  final double? width, height;
  final String text;
  final Color? colorButton;
  final Color? colorBorder;
  final Color? colorText;
  final bool? showShadow;

  const ButtonsShared({
    super.key,
    required this.onPressed,
    required this.text,
    this.width = 327,
    this.height = 50,
    this.colorText = ColorManager.white,
    this.colorButton = ColorManager.primary,
    this.colorBorder = ColorManager.primary,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all<Size>(
          Size(width!.w, height!.h),
        ),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
              side: BorderSide(color: colorBorder!, width: 1.w)),
        ),
        elevation: showShadow! ? WidgetStateProperty.all(6) : null,
        shadowColor: showShadow!
            ? WidgetStateProperty.all<Color>(
                ColorManager.secondary.withValues(alpha: 0.50))
            : null,
        backgroundColor: WidgetStateProperty.all(colorButton),
      ),
      child: Text(
        text,
        style: AppStyles.title16Medium.copyWith(
          color: colorText,
        ),
      ),
    );
  }
}

class ButtonDottedShared extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool disable;
  const ButtonDottedShared({
    super.key,
    required this.onPressed,
    required this.text,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DottedBorder(
        dashPattern: const [5, 5, 1, 0],
        borderType: BorderType.RRect,
        color: disable ? ColorManager.divider : ColorManager.primary,
        radius: Radius.circular(8.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
          ),
          height: 50.h,
          width: 327.w,
          child: Center(
            child: Text(
              text,
              style: AppStyles.title16Medium.copyWith(
                color: disable ? ColorManager.divider : ColorManager.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonRowShared extends StatelessWidget {
  final String buttonText;
  const ButtonRowShared({
    super.key,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
      decoration: BoxDecoration(
          border: Border.all(color: ColorManager.primary),
          borderRadius: BorderRadius.circular(8.r),
          color: ColorManager.primary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            buttonText,
            style: AppStyles.body14Medium.copyWith(color: ColorManager.white),
          ),
        ],
      ),
    );
  }
}
