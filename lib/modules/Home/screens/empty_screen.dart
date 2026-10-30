import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';

class EmptyScreen extends StatelessWidget {
  bool notification;
  String text;
  EmptyScreen({super.key, required this.notification, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          notification ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: <Widget>[
        notification
            ? SizedBox()
            : Text(
                translate(AppStrings.newRequests),
                style: AppStyles.body14Medium
                    .copyWith(color: ColorManager.darkGrey),
              ),
        notification
            ? SizedBox()
            : SizedBox(
                height: 50.h,
              ),
        Center(
          child: Lottie.asset(
            'assets/empty.json',
            repeat: true,
            width: 66.w,
            height: 66.h,
          ),
        ),
        SizedBox(
          height: 30.h,
        ),
        Center(
          child: SizedBox(
            width: 225.w,
            child: Text(
              translate(text),
              textAlign: TextAlign.center,
              style: AppStyles.caption12Regular
                  .copyWith(color: ColorManager.medGray),
            ),
          ),
        ),
        Expanded(child: SizedBox()),
      ],
    );
  }
}
