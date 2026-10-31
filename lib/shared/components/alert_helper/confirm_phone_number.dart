import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class ConfirmPhoneNumber extends StatelessWidget {
  final String phoneNumber;
  final String userName;
  final String? email;
  final bool comeFromSignUpScreen;

  const ConfirmPhoneNumber({
    super.key,
    required this.phoneNumber,
    required this.userName,
    this.email,
    required this.comeFromSignUpScreen,
  });

  @override
  Widget build(BuildContext context) {
    return KDialog(
      // The phone number is isolated so it stays left-to-right in Arabic.
      title:
          '${translate(AppStrings.sendVerificationCode)} \u2066$phoneNumber\u2069 ?',
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.changeNumber),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
