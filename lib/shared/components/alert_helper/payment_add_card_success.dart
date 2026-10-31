import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

class PaymentAddCardSuccess extends StatelessWidget {
  const PaymentAddCardSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: SvgPicture.asset(
        AssetsManager.paymentSuccess,
        height: 88,
        fit: BoxFit.contain,
      ),
      title: translate(AppStrings.paymentSuccessful),
      message: translate(AppStrings.thankYouForYouSubscribing),
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.back),
          variant: KButtonVariant.text,
          onPressed: () {
            popALlAndPushPage(context, MainNavigationScreen(selectedIndex: 3));
          },
        ),
      ],
    );
  }
}
