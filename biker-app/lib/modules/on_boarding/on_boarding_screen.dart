import 'dart:math' as math;
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/modules/on_boarding/on_boarding_model.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class OnboardScreen extends StatefulWidget implements KFullWidthPage {
  const OnboardScreen({super.key});

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  static late int currentIndex;
  late PageController _controller;
  late List<BoardingModel> onBoardingModel;

  @override
  void initState() {
    super.initState();
    onBoardingModel = BoardingModel.listOnBoarding;
    currentIndex = 0;
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (currentIndex == onBoardingModel.length - 1) {
      popALlAndPushPage(context, LogInScreen());
    } else {
      _controller.nextPage(
        duration: KMotion.of(context, KMotion.slow),
        curve: KMotion.curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool last = currentIndex == onBoardingModel.length - 1;
    final BoardingModel page = onBoardingModel[currentIndex];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView(
              controller: _controller,
              onPageChanged: (int index) =>
                  setState(() => currentIndex = index),
              children: <Widget>[
                for (final BoardingModel e in onBoardingModel)
                  Image.asset(
                    e.image,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
              ],
            ),
            // Scrim so white text stays readable on any photo.
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0x33000000),
                      Color(0x00000000),
                      Color(0xE6000000),
                    ],
                    stops: <double>[0, 0.4, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  math.max(
                    KSpace.xxl,
                    (MediaQuery.sizeOf(context).width - 480) / 2,
                  ),
                  KSpace.s,
                  math.max(
                    KSpace.xxl,
                    (MediaQuery.sizeOf(context).width - 480) / 2,
                  ),
                  KSpace.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: last
                          ? const SizedBox(height: KSpace.tapTarget)
                          : KButton(
                              label: translate(AppStrings.skip),
                              variant: KButtonVariant.secondary,
                              expand: false,
                              onPressed: () =>
                                  popALlAndPushPage(context, LogInScreen()),
                            ),
                    ),
                    const Spacer(),
                    Text(
                      translate(page.title),
                      style: KType.largeTitle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: KSpace.s),
                    Text(
                      translate(page.body),
                      style: KType.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: KSpace.xxl),
                    Row(
                      children: <Widget>[
                        for (int i = 0; i < onBoardingModel.length; i++)
                          AnimatedContainer(
                            duration: KMotion.of(context, KMotion.fast),
                            margin: const EdgeInsetsDirectional.only(
                              end: KSpace.s,
                            ),
                            height: 8,
                            width: i == currentIndex ? 24 : 8,
                            decoration: ShapeDecoration(
                              shape: const StadiumBorder(),
                              color: Colors.white.withValues(
                                alpha: i == currentIndex ? 1 : 0.45,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: KSpace.xxl),
                    KButton(
                      label: translate(
                        last ? AppStrings.getStarted : AppStrings.next,
                      ),
                      onPressed: _next,
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
