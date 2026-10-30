
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';

class PinCodeWidget extends StatelessWidget {
  final TextEditingController codeController;
  final Function(String) onCompleted;
  const PinCodeWidget({
    super.key,
    required this.codeController,
    required this.onCompleted,
    });

  @override
  Widget build(BuildContext context) {
    return Directionality(
             textDirection: TextDirection.ltr,
             child: PinCodeTextField(
               appContext: context,
               length: 6,
               obscuringCharacter: '*',
               animationType: AnimationType.fade,
               validator: (String? v) {
                 if (v!.length < 6) {
                   return translate(AppStrings.pinCode);
                 } else {
                   return null;
                 }
               },
               pinTheme: PinTheme(
                   shape: PinCodeFieldShape.box,
                   borderRadius: BorderRadius.circular(10.r),
                   fieldHeight: 45.h,
                   fieldWidth: 40.w,
                   selectedColor: ColorManager.primary,
                   activeColor: ColorManager.primaryLight,
                   activeFillColor: ColorManager.primaryLight,
                   inactiveFillColor: ColorManager.white,
                   selectedFillColor: ColorManager.white,
                   inactiveColor: ColorManager.primaryLight),
               cursorColor: Colors.black,
               animationDuration:
                   const Duration(milliseconds: 300),
               hintCharacter: "_",
               textStyle: AppStyles.headlines24Regular,
               enableActiveFill: true,
               controller: codeController,
               keyboardType: TextInputType.number,
               inputFormatters: <TextInputFormatter>[
                 FilteringTextInputFormatter.allow(
                     RegExp(r'[0-9]')),
               ],
               onCompleted: onCompleted,
               onChanged: (String value) {},
               beforeTextPaste: (String? text) {
                 return true;
               },
             ),
       );
  }
}