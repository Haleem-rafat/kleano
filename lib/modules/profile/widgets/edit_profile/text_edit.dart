import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class TextEdit extends StatelessWidget {
  const TextEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        height: 30.h,
        width: 60.w,
        child: Row(
          children: <Widget>[
            Icon(Icons.edit_outlined, size: 14.r, color: ColorManager.medGray),
            Text(
              translate(AppStrings.editProfile),
              style: AppStyles.titleGray16Regular.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
