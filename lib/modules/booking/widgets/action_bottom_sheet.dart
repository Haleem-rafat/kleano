import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class ActionsBottom extends StatelessWidget {
  final Function() onDateSelected;
  const ActionsBottom({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              onPressed: () {
                pop(context);
              },
              child: Text(
                translate(AppStrings.cancel),
                style: AppStyles.body14Medium.copyWith(
                  color: ColorManager.thirdColor400,
                ),
              ),
            ),
            8.horizontalSpace,
            TextButton(
              onPressed: () {
                onDateSelected();
              },
              child: Text(
                translate(AppStrings.ok),
                style: AppStyles.body14Medium.copyWith(
                  color: ColorManager.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
