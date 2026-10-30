import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/screens/home_screen.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class RatingSuccessDialog extends StatefulWidget {
  const RatingSuccessDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<RatingSuccessDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingSuccessDialog> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      pushReplacement(
          context,
          HomeScreen(
            initialIndex: 0,
          ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      elevation: 0.6,
      backgroundColor: Colors.transparent,
      insetAnimationCurve: Curves.easeInOut,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Localizations.localeOf(context).languageCode == "en"
                  ? SvgPicture.asset(ImageAssets.ratingLogoSvg)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: SvgPicture.asset(ImageAssets.ratingLogoSvg),
                    ),
            ),
            Center(
              child: Text(
                translate(AppStrings.reviewSuccessfullySubmitted),
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Center(
              child: Text(
                translate(AppStrings.thankOpinion),
                style: AppStyles.caption12Regular.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
            ),
            SizedBox(
              height: 32.h,
            ),
          ],
        ),
      ),
    );
  }
}
