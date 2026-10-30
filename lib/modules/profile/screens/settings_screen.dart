import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/drop_down_language.dart';
import 'package:thewhsherbiker/shared/components/app_bar.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          titleText: translate(AppStrings.settings),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 25.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p14.w),
              child: Text(
                translate(AppStrings.language),
                style: AppStyles.title16Regular.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
            ),
            16.verticalSpace,
            const DropDownLanguage(),
            // 16.verticalSpace,
          ],
        ),
      ),
    );
  }
}
