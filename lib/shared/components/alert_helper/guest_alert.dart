import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/utilties/navigator.dart';

class GuestAlert extends StatelessWidget {
  const GuestAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: SvgPicture.asset(AssetsManager.guest),
      title: translate(AppStrings.yourNotRegisteredYet),
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.signUpNow),
          onPressed: () => popALlAndPushPage(context, ChooseRegisterView()),
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
