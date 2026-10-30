import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/on_boarding/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final List<Widget> screens;
  late final Timer timer;
  late int listToShowIndex;
  late AnimationController _controllerContainer;
  late Animation<double> _animation;
  late AnimationController _controllerA;

  @override
  void initState() {
    listToShowIndex = 0;
    screens = <Widget>[
      Container(
        color: ColorManager.white,
      ),
      Container(color: ColorManager.white),
      const OnboardScreen(),
    ];
    _controllerA = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controllerA,
      curve: Curves.bounceOut,
    );
    Future<void>.delayed(
      const Duration(milliseconds: 500),
      () {
        timer = Timer.periodic(
          const Duration(milliseconds: 1000),
          (_) {
            if (listToShowIndex != 2) {
              setState(() {
                listToShowIndex++;
              });
            }
          },
        );
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    _controllerA.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        backgroundColor: ColorManager.white,
        body: Stack(
          children: [
            SizedBox(
              height: 1.sh,
              width: 1.sw,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: listToShowIndex == 0
                    ? SizedBox(
                        key: const Key('Splash1'),
                        child: screens[listToShowIndex])
                    : listToShowIndex == 1
                        ? SizedBox(
                            key: const Key('Splash2'),
                            child: screens[listToShowIndex],
                          )
                        : SizedBox(
                            key: const Key('Splash3'),
                            child: screens[listToShowIndex],
                          ),
              ),
            ),
            if (listToShowIndex != screens.length - 1)
              Positioned(
                top: 0.h,
                right: 0.w,
                child: IgnorePointer(
                  child: SvgPicture.asset(
                    AssetsManager.shapCircleRight,
                  ),
                ),
              ),
            if (listToShowIndex != screens.length - 1)
              Positioned(
                top: 0.h,
                left: 0.w,
                child: IgnorePointer(
                  child: SvgPicture.asset(
                    AssetsManager.shapCircleLeft,
                  ),
                ),
              ),
            if (listToShowIndex == 1)
              Center(
                child: ScaleTransition(
                  scale: _animation,
                  child: SvgPicture.asset(AssetsManager.logo),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
