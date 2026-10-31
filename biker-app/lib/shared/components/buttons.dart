import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
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

  /// Filled (opaque, coloured) buttons map to Apple's prominent glass.
  bool get _isProminent =>
      colorButton != null &&
      colorButton!.a > 0.5 &&
      colorButton!.toARGB32() != ColorManager.white.toARGB32();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height!.h,
      width: width!.w,
      // iOS: Apple's real glass button; other platforms: the Material button.
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
        foreground: textStyle.color ?? colorText,
        fontSize: textStyle.fontSize ?? 16,
        fallback: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            fixedSize: Size(width!.w, height!.h),
            // Continuous (superellipse) corners, Liquid Glass style.
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius.r)),
              side: BorderSide(color: colorBorder!, width: 1.w),
            ),
            elevation: showShadow! ? 4 : 0,
            shadowColor: showShadow!
                ? ColorManager.secondary.withValues(alpha: .35)
                : Colors.transparent,
            overlayColor: ColorManager.white.withValues(alpha: 0.12),
            backgroundColor: colorButton,
            foregroundColor: colorText, // Handles the text color in Material 3
          ),
          child: Text(text, style: textStyle),
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
        options: RoundedRectDottedBorderOptions(
          dashPattern: const <double>[4, 3, 1, 0],
          color: disable ? ColorManager.divider : ColorManager.primary,
          radius: const Radius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
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
