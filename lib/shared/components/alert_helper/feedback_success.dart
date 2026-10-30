import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class FeedbackSuccessSubmit extends StatelessWidget {
  const FeedbackSuccessSubmit({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
    return StatefulBuilder(
      builder: (BuildContext context, Function setState) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                border: Border.all(color: ColorManager.darkGrey),
              ),
              padding: EdgeInsets.fromLTRB(
                8.44.w,
                7.h,
                8.44.w,
                73.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 316.w,
                    height: 138.h,
                    child: Stack(alignment: Alignment.bottomCenter, children: [
                      Positioned(
                          top: 0.h,
                          left: 0.w,
                          child: SvgPicture.asset(AssetsManager.layoutAlert)),
                      Container(
                        height: 64.h,
                        width: 64.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorManager.divider2,
                        ),
                        child: Icon(
                          Icons.check,
                          color: ColorManager.primary,
                          size: 40.w,
                        ),
                      ),
                    ]),
                  ),
                  13.ph,
                  Text(
                    translate(AppStrings.reviewSuccessfullySubmitted),
                    style: AppStyles.title16Bold.copyWith(
                      color: ColorManager.darkGrey,
                    ),
                  ),
                  AppPadding.p10.ph,
                  Text(
                    translate(AppStrings.thankYouForYourOpinion),
                    style: AppStyles.caption12Regular.copyWith(
                      color: ColorManager.darkGrey,
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}
