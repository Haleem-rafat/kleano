import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';

class EditAccountContainer extends StatelessWidget {
  final bool edit;
  final String title;
  const EditAccountContainer({Key? key, required this.edit, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: 326.w,
        decoration: BoxDecoration(
          color: ColorManager.gray,
          borderRadius: BorderRadius.circular(5.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Row(
          children: <Widget>[
            Text(
              "${title} :",
              style: AppStyles.body14Medium.copyWith(color: ColorManager.darkGrey),
            ),
            Spacer(),
            SizedBox(
              height: 30.h,
              // width: 50.w,
              child: Visibility(
                visible: edit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.edit_outlined,
                      color: ColorManager.darkGrey,
                      size: 15.r,
                    ),
                    2.horizontalSpace,
                    Text(
                      translate(AppStrings.edit),
                      style: AppStyles.subtext14Regular.copyWith(
                          color: ColorManager.darkGrey, decoration: TextDecoration.underline, decorationColor: ColorManager.darkGrey),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
