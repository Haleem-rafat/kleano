import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class PointAlert extends StatelessWidget {
  const PointAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: Lottie.asset(
        'assets/point.json',
        repeat: true,
        width: 88,
        height: 88,
      ),
      title: translate(AppStrings.howPointsWorks),
      message:
          '${translate(AppStrings.watchPointsGrow)}\n'
          '${translate(AppStrings.certainNumberPoints)}\n\n'
          '${translate(AppStrings.redeemPoints)}\n'
          '${translate(AppStrings.certainAmountPoints)}',
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.continueExplore),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
