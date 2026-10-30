import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';

class CardProfileInformation extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconName;
  final bool? showRating;
  const CardProfileInformation({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconName,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: const BorderRadius.all(Radius.circular(AppSize.s12)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: ColorManager.black.withOpacity(.06),
                blurRadius: 6.r,
                offset: const Offset(0, 3))
          ]),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(iconName),
              SizedBox(
                width: 2.w,
              ),
              Text(
                title,
                style: AppStyles.title16Regular.copyWith(
                  color: ColorManager.medGray,
                  fontSize: FontSize.s10.sp,
                ),
              ),
            ],
          ),
          9.verticalSpace,
          Container(
            height: 1.h,
            color: ColorManager.divider,
            width: 65.w,
          ),
          3.verticalSpace,
          showRating == true
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      subtitle,
                      style: AppStyles.body14Medium.copyWith(
                        color: ColorManager.darkGrey,
                      ),
                    ),
                    2.horizontalSpace,
                    SizedBox(
                        height: 14.h,
                        width: 14.w,
                        child: SvgPicture.asset(ImageAssets.starSelected)),
                  ],
                )
              : Text(
                  subtitle,
                  style: AppStyles.body14Medium.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
        ],
      ),
    );
  }
}
