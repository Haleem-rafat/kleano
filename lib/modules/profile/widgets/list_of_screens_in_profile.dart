import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/about_us/screens/about_us_screen.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/screens/profile_account/profile_account.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/modules/profile/screens/profile_account/setting/setting_screen.dart';
import 'package:thewasher/modules/profile/widgets/container_shadow.dart';
import 'package:thewasher/utilties/navigator.dart';

class ScreensInProfile extends StatefulWidget {
  final Profile profile;
  const ScreensInProfile({super.key, required this.profile});

  @override
  State<ScreensInProfile> createState() => _ScreensInProfileState();
}

class _ScreensInProfileState extends State<ScreensInProfile> {
  late final Map<String, _ScreenItem> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = {
      translate(AppStrings.account): _ScreenItem(
        screen: const ProfileAccountScreen(),
        icon: Icons.person_outline_rounded,
      ),
      // translate(AppStrings.subscriptions): _ScreenItem(
      //   screen: PlansAndSubscriptionScreen(profile: widget.profile),
      //   icon: Icons.card_membership_rounded,
      // ),

      translate(AppStrings.promoCodes): _ScreenItem(
        screen: const PromoCodeScreen(),
        icon: Icons.local_offer_outlined,
      ),
      translate(AppStrings.settings): _ScreenItem(
        screen: const SettingScreen(),
        icon: Icons.settings_outlined,
      ),
      translate(AppStrings.aboutUs): _ScreenItem(
        screen: const AboutUsScreen(),
        icon: Icons.info_outline_rounded,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: AppPadding.p20.h, bottom: AppPadding.p20.h),
      itemCount: _screens.length,
      itemBuilder: (BuildContext context, int index) {
        final entry = _screens.entries.elementAt(index);
        return ContainerShadow(
          onPressed: () => pushPage(context, entry.value.screen),
          text: entry.key,
          icon: entry.value.icon,
        );
      },
    );
  }
}

class _ScreenItem {
  final Widget screen;
  final IconData icon;

  _ScreenItem({required this.screen, required this.icon});
}
