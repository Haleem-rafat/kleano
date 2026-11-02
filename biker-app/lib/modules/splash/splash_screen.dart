import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/biker_shell.dart';
import 'package:thewhsherbiker/modules/on_boarding/on_boarding_screen.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class SplashScreen extends StatefulWidget implements KFullWidthPage {
  const SplashScreen({super.key});

  /// Longest the profile may hold the splash; a late answer still reaches Home.
  static const Duration profileWait = Duration(seconds: 8);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _profileWait;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (prefs.containsKey('FirstTime')) {
      sl<AuthBloc>().add(BikerSplash());
    } else {
      changeLocale(context, 'en');
      pushPage(context, const OnboardScreen());
    }
  }

  /// A signed-in biker never waits for GPS, which can take minutes indoors.
  void _openForSignedInBiker() {
    unawaited(
      sl<AuthBloc>().getUserLocation().catchError(
        (Object e) => debugPrint('Location unavailable: $e'),
      ),
    );
    if (sl<ProfileBloc>().profile.userName != null) {
      _leaveTo(BikerShell(initialIndex: 0));
      return;
    }
    _profileWait = Timer(
      SplashScreen.profileWait,
      () => _leaveTo(BikerShell(initialIndex: 0)),
    );
    sl<ProfileBloc>().add(BikerProfile());
  }

  void _leaveTo(Widget page) {
    if (_left || !mounted) return;
    _left = true;
    _profileWait?.cancel();
    popALlAndPushPage(context, page);
  }

  @override
  void dispose() {
    _profileWait?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: KColors.light.brand,
        body: BlocListener<ProfileBloc, ProfileState>(
          bloc: sl<ProfileBloc>(),
          listener: (BuildContext context, ProfileState state) {
            if (state is BikerProfileSuccess || state is BikerProfileFailed) {
              _leaveTo(BikerShell(initialIndex: 0));
            }
          },
          child: BlocListener<AuthBloc, AuthState>(
            bloc: sl<AuthBloc>(),
            listener: (BuildContext context, AuthState state) {
              if (state is BikerSplashAlreadyUser) {
                _openForSignedInBiker();
              } else if (state is BikerSplashExpiredToken ||
                  state is BikerSplashNotUser) {
                _leaveTo(LogInScreen());
              }
            },
            // The same logo the phone shows while the app starts, so it holds
            // still when Flutter takes over.
            child: Center(
              child: SvgPicture.asset(ImageAssets.logoWhite, width: 173),
            ),
          ),
        ),
      ),
    );
  }
}
