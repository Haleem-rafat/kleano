import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class PayWithWalletNotEnoughAmount extends StatelessWidget {
  const PayWithWalletNotEnoughAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      title: translate(AppStrings.yourWalletNotEnoughRefundYourWalletFirst),
      actions: <Widget>[
        KButton(label: translate(AppStrings.recharge), onPressed: () {}),
        KButton(
          label: translate(AppStrings.cancel),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
