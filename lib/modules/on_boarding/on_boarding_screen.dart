import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/on_boarding/on_boarding_model.dart';
import 'package:thewasher/utilties/navigator.dart';

class OnboardScreen extends StatefulWidget {
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
    currentIndex = 0;
    _controller = PageController();
    onBoardingModel = BoardingModel.listOnBoarding;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (currentIndex == onBoardingModel.length - 1) {
      popALlAndPushPage(context, ChooseRegisterView());
    } else {
      _controller.nextPage(
        duration: KMotion.of(context, KMotion.slow),
        curve: KMotion.curve,
      );
    }
  }

  void _toggleLanguage() {
    final String newLocale =
        Localizations.localeOf(context).languageCode == 'en' ? 'ar' : 'en';
    changeLocale(context, newLocale);
    setState(() => AppShared.lang = newLocale);
    popALlAndPushPage(context, const OnboardScreen());
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
                padding: const EdgeInsets.fromLTRB(
                  KSpace.xxl,
                  KSpace.s,
                  KSpace.xxl,
                  KSpace.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        KButton(
                          label:
                              Localizations.localeOf(context).languageCode ==
                                  'en'
                              ? AppConstants.arabic
                              : AppConstants.english,
                          variant: KButtonVariant.secondary,
                          // White label: brand purple is unreadable on glass over a dark photo.
                          color: Colors.white,
                          expand: false,
                          onPressed: _toggleLanguage,
                        ),
                        const Spacer(),
                        if (!last)
                          KButton(
                            label: translate(AppStrings.skip),
                            variant: KButtonVariant.secondary,
                            // White label: brand purple is unreadable on glass over a dark photo.
                            color: Colors.white,
                            expand: false,
                            onPressed: () =>
                                pushPage(context, ChooseRegisterView()),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      page.title,
                      style: KType.largeTitle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: KSpace.s),
                    Text(
                      page.body,
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
