import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/about_us/screens/contact_us_screen.dart';
import 'package:thewasher/modules/about_us/screens/terms_and_conditions.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/screens/points_explanation_screen.dart';
import 'package:thewasher/modules/profile/widgets/container_shadow.dart';
import 'package:thewasher/utilties/navigator.dart';

class ScreensInGuestProfile extends StatefulWidget {
  const ScreensInGuestProfile({super.key});

  @override
  State<ScreensInGuestProfile> createState() => _ScreensInGuestProfileState();
}

class _ScreensInGuestProfileState extends State<ScreensInGuestProfile> {
  late List<String> profileScreens;
  late List<Widget> widgets;

  @override
  void initState() {
    super.initState();
    profileScreens = <String>[
      translate(AppStrings.subscriptions),
      translate(AppStrings.termsAndConditions),
      translate(AppStrings.contactUs),
      translate(AppStrings.howPointsWorks),
    ];
    widgets = <Widget>[
      const PlansAndSubscriptionScreen(),
      const TermsAndConditionsScreen(),
      const ContactUsScreen(),
      const PointsExplanationScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.p26.h),
      child: Column(
        children: profileScreens.asMap().keys.map((int index) {
          return ContainerShadow(
            onPressed: () {
              pushPage(context, widgets[index]);
            },
            text: profileScreens[index],
          );
        }).toList(),
      ),
    );
  }
}
