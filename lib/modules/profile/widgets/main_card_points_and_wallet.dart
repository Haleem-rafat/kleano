import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class MainCardPointsAndWallet extends StatelessWidget {
  final Widget numberText;
  final String titleText;
  final String image;
  final VoidCallback onPressed;
  const MainCardPointsAndWallet({
    super.key,
    required this.onPressed,
    required this.image,
    required this.titleText,
    required this.numberText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 150.w,
          padding: EdgeInsets.fromLTRB(0.w, 11.h, 0.w, 14.h),
          decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: ColorManager.black.withValues(alpha: .05),
                    blurRadius: 3.r,
                    offset: const Offset(0, 3))
              ]),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      image,
                      colorFilter: ColorFilter.mode(ColorManager.secondary, BlendMode.srcIn),
                      height: AppSize.s20.h,
                      width: AppSize.s20.w,
                    ),
                    AppPadding.p8.pw,
                    Text(
                      titleText,
                      style: AppStyles.titleGray16Regular.copyWith(
                        color: ColorManager.black,
                      ),
                    ),
                  ],
                ),
                AppPadding.p8.ph,
                Center(child: numberText)
              ]),
        ));
  }
}
