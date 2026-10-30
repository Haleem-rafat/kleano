import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/about_us/screens/contact_us_screen.dart';
import 'package:thewasher/modules/about_us/screens/terms_and_conditions.dart';
import 'package:thewasher/modules/profile/widgets/container_shadow.dart';
import 'package:thewasher/shared/components/app_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          titleText: translate(AppStrings.aboutUs),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(children: <Widget>[
          ContainerShadow(
            onPressed: () {
              pushPage(context, const TermsAndConditionsScreen());
            },
            text: translate(AppStrings.termsAndConditions),
          ),
          ContainerShadow(
            onPressed: () {
              pushPage(context, const ContactUsScreen());
            },
            text: translate(AppStrings.contactUs),
          ),
        ]),
      ),
    );
  }
}
