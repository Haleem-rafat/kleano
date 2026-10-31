import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';

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
  late final PinInputController _pinController = PinInputController(
    textController: widget.codeController,
  );

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Six cells fit any width: up to 48pt each, smaller on narrow screens.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        const int cells = 6;
        final double cell = ((c.maxWidth - KSpace.s * (cells - 1)) / cells)
            .clamp(36.0, 48.0)
            .floorToDouble();
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
              cellSize: Size(cell, 56),
              spacing: KSpace.s,
              borderRadius: BorderRadius.circular(KRadius.field),
              borderWidth: 0,
              focusedBorderWidth: 2,
              fillColor: KColors.of(context).fill,
              focusedFillColor: KColors.of(context).surface,
              filledFillColor: KColors.of(context).fill,
              borderColor: Colors.transparent,
              filledBorderColor: Colors.transparent,
              focusedBorderColor: KColors.of(context).brand,
              errorBorderColor: KColors.of(context).error,
              textStyle: KType.title.copyWith(color: KColors.of(context).text),
              cursorColor: KColors.of(context).brand,
              entryAnimation: MaterialPinAnimation.fade,
              animationDuration: KMotion.fast,
            ),
          ),
        );
      },
    );
  }
}
