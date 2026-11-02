import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/on_boarding/on_boarding_screen.dart';
import 'package:thewasher/modules/splash/address_check_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

import 'package:thewasher/core/services/appsflyer_service.dart';

class SplashTwoScreen extends StatefulWidget implements KFullWidthPage {
  const SplashTwoScreen({super.key});

  @override
  State<SplashTwoScreen> createState() => _SplashTwoScreenState();
}

class _SplashTwoScreenState extends State<SplashTwoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controllerA;
  late final Animation<double> _animation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    AppsFlyerService.logEvent("af_app_opened");

    _controllerA = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controllerA,
      curve: Curves.bounceOut,
    );

    // Play once and go: the logo animation is the only wait.
    _controllerA.forward().whenComplete(_navigateToNextScreen);
  }

  void _navigateToNextScreen() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool seenOnboarding = prefs.getBool('FirstTime') ?? false;
    await AppShared.getToken();
    await AppShared.getRefreshToken();

    if (!mounted) return;

    if (!seenOnboarding) {
      popALlAndPushPage(context, const OnboardScreen());
    } else {
      if (AppShared.refreshToken.isEmpty ||
          AppShared.isTokenExpired(AppShared.refreshToken)) {
        popALlAndPushPage(context, ChooseRegisterView());
      } else {
        // Navigate to address check screen which will handle location checking
        popALlAndPushPage(context, const AddressCheckScreen());
      }
    }
  }

  @override
  void dispose() {
    _controllerA.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.darkStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        backgroundColor: ColorManager.white,
        body: Stack(
          children: <Widget>[
            Container(color: ColorManager.primary),
            Center(
              child: ScaleTransition(
                scale: _animation,
                child: SvgPicture.asset(AssetsManager.logoWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
