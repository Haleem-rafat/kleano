import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class FeedbackSuccessSubmit extends StatelessWidget {
  const FeedbackSuccessSubmit({super.key});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: Icon(
        Icons.check_circle_rounded,
        size: 48,
        color: KColors.of(context).success,
      ),
      title: translate(AppStrings.reviewSuccessfullySubmitted),
      message: translate(AppStrings.thankYouForYourOpinion),
    );
  }
}
