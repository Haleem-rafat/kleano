import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class ContainerEdit extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const ContainerEdit({
    super.key,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin:
            EdgeInsets.only(top: AppPadding.p16.h, bottom: AppPadding.p12.h),
        padding: EdgeInsets.fromLTRB(AppPadding.p15.w, AppPadding.p10.h,
            AppPadding.p10.w, AppPadding.p9.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          color: ColorManager.gray,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              translate(title),
              style: AppStyles.subtextGray14Regular.copyWith(
                color: ColorManager.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 30.h,
              width: 60.w,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.edit_outlined,
                    size: AppSize.s14.r,
                    color: ColorManager.primary,
                  ),
                  Text(
                    translate(AppStrings.editProfile),
                    style: AppStyles.subtextGray14Regular.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorManager.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorManager.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
