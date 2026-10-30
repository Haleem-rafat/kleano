import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class PinCodeWidget extends StatefulWidget {
  final TextEditingController codeController;
  final Function(String) onCompleted;
  const PinCodeWidget({
    super.key,
    required this.codeController,
    required this.onCompleted,
  });

  @override
  State<PinCodeWidget> createState() => _PinCodeWidgetState();
}

class _PinCodeWidgetState extends State<PinCodeWidget> {
  late final PinInputController _pinController =
      PinInputController(textController: widget.codeController);

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialPinFormField(
        length: 6,
        pinController: _pinController,
        keyboardType: TextInputType.number,
        enableAutofill: true,
        autofillHints: const <String>[AutofillHints.oneTimeCode],
        hintCharacter: '_',
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (String? v) =>
            (v ?? '').length < 6 ? translate(AppStrings.pinCode) : null,
        onCompleted: widget.onCompleted,
        theme: MaterialPinTheme(
          shape: MaterialPinShape.outlined,
          cellSize: Size(40.w, 45.h),
          borderRadius: BorderRadius.circular(10.r),
          fillColor: ColorManager.white,
          focusedFillColor: ColorManager.white,
          filledFillColor: ColorManager.primaryLight,
          borderColor: ColorManager.primaryLight,
          focusedBorderColor: ColorManager.primary,
          filledBorderColor: ColorManager.primaryLight,
          textStyle: AppStyles.headlines24Regular,
          cursorColor: Colors.black,
          entryAnimation: MaterialPinAnimation.fade,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
