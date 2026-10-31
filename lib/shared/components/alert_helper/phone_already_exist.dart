import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class PhoneAlreadyExist extends StatelessWidget {
  final String phoneNumber;
  const PhoneAlreadyExist({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      // The phone number is isolated so it stays left-to-right in Arabic.
      title: '${translate(AppStrings.thisNumberAlreadyExists)} \u2066$phoneNumber\u2069',
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.backToHome),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
