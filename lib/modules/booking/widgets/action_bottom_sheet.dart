import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class ActionsBottom extends StatelessWidget {
  final Function() onDateSelected;
  const ActionsBottom({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KSpace.l,
        vertical: KSpace.s,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            KButton(
              label: translate(AppStrings.cancel),
              variant: KButtonVariant.text,
              expand: false,
              color: KColors.of(context).textSecondary,
              onPressed: () {
                pop(context);
              },
            ),
            const SizedBox(width: KSpace.s),
            KButton(
              label: translate(AppStrings.ok),
              variant: KButtonVariant.text,
              expand: false,
              onPressed: () {
                onDateSelected();
              },
            ),
          ],
        ),
      ),
    );
  }
}
