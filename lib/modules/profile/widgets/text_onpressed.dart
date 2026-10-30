import 'package:flutter/material.dart';
import 'package:thewasher/core/resources/app_styles.dart';

class TextOnPressed extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? textColor;
  final double? fontSize;
  final TextDecoration? textDecoration;
  const TextOnPressed({
    super.key,
    required this.onPressed,
    required this.text,
    this.fontSize,
    this.textDecoration,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        style: textColor != null
            ? AppStyles.titleGray16Regular.copyWith(color: textColor)
            : AppStyles.titleGray16Regular
                .copyWith(decoration: textDecoration, fontSize: fontSize),
      ),
    );
  }
}
