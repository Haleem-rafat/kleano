// import 'package:flutter/material.dart';
// import 'package:thewasher/core/resources/app_styles.dart';

// class TextUnderLineShared extends StatelessWidget {
//   final VoidCallback onTap;
//   final String text;
//   final Color textColor;
//   final TextStyle? textStyle;
//   const TextUnderLineShared({
//     super.key,
//     required this.onTap,
//     required this.text,
//     required this.textColor,
//     textStyle
//     }) : textStyle =  AppStyles.caption12Medium;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//              onTap: onTap,
//              behavior: HitTestBehavior.opaque,
//              child: Text(
//                text,
//                style: textStyle!.copyWith(
//                    color: textColor,
//                    decoration: TextDecoration.underline),
//              ),
//            );
//   }
// }