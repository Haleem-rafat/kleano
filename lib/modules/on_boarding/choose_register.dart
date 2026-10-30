import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/Auth/screens/log_in_screen.dart';
import 'package:thewasher/modules/Auth/screens/sign_up_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

class ChooseRegisterView extends StatefulWidget {
  // bool comeFromMain;
  const ChooseRegisterView({super.key});

  @override
  State<ChooseRegisterView> createState() => _ChooseRegisterViewState();
}

class _ChooseRegisterViewState extends State<ChooseRegisterView> {
  Future<void> checkFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('FirstTime')) {
      prefs.setBool('FirstTime', true);
    }
  }

  @override
  void initState() {
    checkFirstSeen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              AssetsManager.onBoardingFour,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0x40000000),
                      Color(0x00000000),
                      Color(0xD9000000),
                    ],
                    stops: <double>[0, 0.45, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpace.xxl,
                  KSpace.xxl,
                  KSpace.xxl,
                  KSpace.l,
                ),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    SvgPicture.asset(AssetsManager.logoWhite, height: 120),
                    const Spacer(flex: 2),
                    KButton(
                      label: translate(AppStrings.signUp),
                      onPressed: () => pushPage(context, const SignUpScreen()),
                    ),
                    const SizedBox(height: KSpace.m),
                    KButton(
                      label: translate(AppStrings.login),
                      variant: KButtonVariant.secondary,
                      onPressed: () => pushPage(context, const LogInScreen()),
                    ),
                    const SizedBox(height: KSpace.s),
                    KButton(
                      label: translate(AppStrings.continueAsAGuest),
                      variant: KButtonVariant.text,
                      color: Colors.white,
                      onPressed: () {
                        AppShared.setToken("");
                        isGuestUser = true;
                        popALlAndPushPage(
                          context,
                          MainNavigationScreen(selectedIndex: 0),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
