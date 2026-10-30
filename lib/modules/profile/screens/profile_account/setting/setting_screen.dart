import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/widgets/drop_down_language.dart';
import 'package:thewasher/modules/profile/widgets/toggle_notification.dart';
import 'package:thewasher/shared/components/app_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          onTap: () {
            pop(context);
            context
                .read<GetUserProfileBloc>()
                .add(GetUserProfileEvent(isRefresh: true));
          },
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
                  color: ColorManager.black,
                ),
              ),
            ),
            const DropDownLanguage(),
            AppPadding.p16.ph,
            const ToggleNotification()
          ],
        ),
      ),
    );
  }
}
