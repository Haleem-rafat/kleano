import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class EmptyScreen extends StatelessWidget {
  final String image;
  final String text;
  const EmptyScreen({
    Key? key,
    required this.image,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SvgPicture.asset(
          image,
          color: ColorManager.black,
        ),
        Text(
          translate(text),
          style: AppStyles.caption12Medium.copyWith(
            color: ColorManager.black,
          ),
        )
      ],
    );
  }
}
