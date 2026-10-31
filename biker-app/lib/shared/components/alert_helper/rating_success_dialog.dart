import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/components/k_dialog.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/screens/biker_shell.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// Thanks for the rating, then back to Today on its own.
class RatingSuccessDialog extends StatefulWidget {
  const RatingSuccessDialog({super.key});

  @override
  State<RatingSuccessDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingSuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      pushReplacement(context, BikerShell(initialIndex: 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: Icon(Icons.favorite_rounded, color: KColors.of(context).brand),
      title: translate(AppStrings.reviewSuccessfullySubmitted),
      message: translate(AppStrings.thankOpinion),
    );
  }
}
