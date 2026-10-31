import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/guest_flow.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

class SuccessAlert extends StatelessWidget {
  final String message;
  const SuccessAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: Lottie.asset(
        'assets/success.json',
        repeat: true,
        width: 120,
        height: 120,
      ),
      title: message,
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.goToHome),
          variant: KButtonVariant.text,
          onPressed: () {
            popALlAndPushPage(
              context,
              MainNavigationScreen(selectedIndex: LoginFlow.selectedGuestIndex),
            );
          },
        ),
      ],
    );
  }
}
