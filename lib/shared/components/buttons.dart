import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
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

  /// Filled (opaque, coloured) buttons map to Apple's prominent glass.
  bool get _isProminent =>
      colorButton != null &&
      colorButton!.a > 0.5 &&
      colorButton!.toARGB32() != ColorManager.white.toARGB32();

  @override
  Widget build(BuildContext context) {
    final Widget material = ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all<Size>(Size(width!.w, height!.h)),
        // Liquid Glass capsule with a soft brand glow.
        shape: WidgetStateProperty.all<OutlinedBorder>(
          StadiumBorder(
            side: BorderSide(color: colorBorder!, width: 1.w),
          ),
        ),
        elevation: showShadow! ? WidgetStateProperty.all(4) : null,
        shadowColor: showShadow!
            ? WidgetStateProperty.all<Color>(
                ColorManager.secondary.withValues(alpha: 0.35),
              )
            : null,
        overlayColor: WidgetStateProperty.all<Color>(
          ColorManager.white.withValues(alpha: 0.12),
        ),
        backgroundColor: WidgetStateProperty.all(colorButton),
      ),
      child: Text(
        text,
        style: AppStyles.title16Medium.copyWith(color: colorText),
      ),
    );
    // iOS: Apple's real glass button; other platforms: the Material button.
    return SizedBox(
      width: width!.w,
      height: height!.h,
      child: NativeGlassButton(
        onPressed: onPressed,
        title: text,
        style: _isProminent
            ? GlassButtonStyle.prominent
            // Apple: clear glass for controls over photos/media.
            : (colorButton?.a ?? 0) < 0.5
                ? GlassButtonStyle.clear
                : GlassButtonStyle.glass,
        tint: _isProminent ? colorButton : null,
        foreground: colorText,
        fontSize: AppStyles.title16Medium.fontSize ?? 16,
        fallback: material,
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
        options: RoundedRectDottedBorderOptions(
          dashPattern: const <double>[5, 5, 1, 0],
          color: disable ? ColorManager.divider : ColorManager.primary,
          radius: Radius.circular(8.r),
        ),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
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
  const ButtonRowShared({super.key, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
      decoration: BoxDecoration(
        border: Border.all(color: ColorManager.primary),
        borderRadius: BorderRadius.circular(8.r),
        color: ColorManager.primary,
      ),
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
