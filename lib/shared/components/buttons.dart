import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';

class ButtonsShared extends StatelessWidget {
  final VoidCallback onPressed;
  final double? width, height;
  final double borderRadius;
  final String text;
  final Color? colorButton;
  final Color? colorBorder;
  final Color? colorText;
  final bool? showShadow;
  final TextStyle textStyle;

  const ButtonsShared({
    super.key,
    required this.onPressed,
    required this.text,
    required this.borderRadius,
    this.width = 327,
    this.height = 50,
    required this.textStyle,
    this.colorText = ColorManager.white,
    this.colorButton = ColorManager.primary,
    this.colorBorder = ColorManager.primary,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(width!.w, height!.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius.r)),
            side: BorderSide(color: colorBorder!, width: 1.w),
          ),
          elevation: showShadow! ? 6 : 0,
          shadowColor: showShadow!
              ? ColorManager.secondary.withOpacity(.50)
              : Colors.transparent,
          backgroundColor: colorButton,
          foregroundColor: colorText, // Handles the text color in Material 3
        ),
        child: Text(
          text,
          style: textStyle,
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
        dashPattern: const [4, 3, 1, 0],
        borderType: BorderType.RRect,
        color: disable ? ColorManager.divider : ColorManager.primary,
        radius: const Radius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          height: 50.h,
          width: 327.w,
          child: Center(
            child: Text(
              text,
              style: AppStyles.title16Bold.copyWith(
                color: disable ? ColorManager.divider : ColorManager.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
