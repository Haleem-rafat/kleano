import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/widgets/wallet_topup_bottom_sheet.dart';
import 'package:thewasher/utilties/navigator.dart';

class PayWithWalletNotEnoughAmount extends StatelessWidget {
  const PayWithWalletNotEnoughAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      title: translate(AppStrings.yourWalletNotEnoughRefundYourWalletFirst),
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.recharge),
          onPressed: () {
            pop(context);
            pushPage(context, const WalletTopupScreen());
          },
        ),
        KButton(
          label: translate(AppStrings.cancel),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
