import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class PhoneNumberWidget extends StatelessWidget {
  final String counteryCode;
  final String phoneNumber;
  const PhoneNumberWidget({
    super.key,
    required this.counteryCode,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w, vertical: AppSize.s4.h),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: <Widget>[
            Text(
              '($counteryCode)',
              style: AppStyles.titleGray16Regular.copyWith(
                color: ColorManager.darkGrey,
              ),
            ),
            AppPadding.p10.pw,
            Text(
              phoneNumber,
              style: AppStyles.titleGray16Regular,
            ),
          ],
        ),
      ),
    );
  }
}
