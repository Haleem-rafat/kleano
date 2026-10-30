import 'package:control_style/control_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';

// Custom input formatter for car plate numbers (English letters and numbers only)
class CarPlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any characters that are not English letters or numbers
    final filteredText = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Convert to uppercase for consistency
    final upperCaseText = filteredText.toUpperCase();

    return TextEditingValue(
      text: upperCaseText,
      selection: TextSelection.collapsed(offset: upperCaseText.length),
    );
  }
}

Widget editCarTitle(String title) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Text(
      translate(title),
      style: AppStyles.title16Regular.copyWith(color: ColorManager.black),
    ),
  );
}

Widget editTextForm(
    String hint, TextEditingController controller, FocusNode focusNode,
    {List<TextInputFormatter>? inputFormatters, TextInputType? keyboardType}) {
  return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType ?? TextInputType.name,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        hintText: hint,
        border: DecoratedInputBorder(
          child: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14.r),
          ),
          shadow: <BoxShadow>[
            BoxShadow(
                color: ColorManager.black2.withValues(alpha: 0.1), blurRadius: 6.r)
          ],
        ),
        prefixIconConstraints: BoxConstraints(
          maxWidth: 80.w,
        ),
      ),
      style: AppStyles.subtext14Regular);
}

Widget? vehiclesType(String type) {
  switch (type) {
    case "Sedan":
      return SvgPicture.asset(
        AssetsManager.sedanImg,
        width: 23.w,
        height: 11.h,
      );
    case "Hatchback":
      return SvgPicture.asset(
        AssetsManager.hatchbackImg,
        width: 23.w,
        height: 11.h,
      );
    case "SUV":
      return SvgPicture.asset(
        AssetsManager.SUVImg,
        width: 23.w,
        height: 11.h,
      );
    case "Van":
      return SvgPicture.asset(
        AssetsManager.vanImg,
        width: 23.w,
        height: 11.h,
      );
    case "Sport Car":
      return SvgPicture.asset(
        AssetsManager.sportCarImg,
        width: 23.w,
        height: 11.h,
      );
  }
  return null;
}
