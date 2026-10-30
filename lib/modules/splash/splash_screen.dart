import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/home_screen.dart';
import 'package:thewhsherbiker/modules/on_boarding/on_boarding_screen.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controllerA;
  bool login = true;
  bool check = false;

  Future<void> _setupController() async {
    _controllerA = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controllerA,
      curve: Curves.bounceOut,
    );
    goToNextView();
  }

  @override
  void initState() {
    _setupController();
    super.initState();
  }

  void _defaultRoot() {
    setState(() {
      changeLocale(context, 'en');
    });
    pushPage(context, const OnboardScreen());
  }

  void goToNextView() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      _controllerA.forward();
    });
    Future.delayed(const Duration(milliseconds: 3300), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('FirstTime')) {
        // Add a timeout to prevent infinite loading
        sl<AuthBloc>().add(BikerSplash());

        // Add a fallback timeout in case the auth process gets stuck
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            // If still on splash after 10 seconds, check if we have valid tokens
            _checkTokenAndNavigate();
          }
        });
      } else {
        _defaultRoot();
      }
    });
  }

  void _checkTokenAndNavigate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('Token');

    if (token != null && token.isNotEmpty) {
      // If we have a token, try to get user location and navigate to home
      sl<AuthBloc>().getUserLocation().whenComplete(() {
        if (sl<ProfileBloc>().profile.userName == null) {
          sl<ProfileBloc>().add(BikerProfile());
        }
      });
    } else {
      // No token, go to login
      if (mounted) {
        popALlAndPushPage(context, LogInScreen());
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
        body: BlocConsumer<ProfileBloc, ProfileState>(
          bloc: sl<ProfileBloc>(),
          listener: (BuildContext context, ProfileState state) {
            if (state is BikerProfileSuccess) {
              popALlAndPushPage(
                context,
                HomeScreen(
                  initialIndex: 0,
                ),
              );
            }
          },
          builder: (BuildContext context, ProfileState profileState) {
            return BlocConsumer<AuthBloc, AuthState>(
              bloc: sl<AuthBloc>(),
              listener: (BuildContext context, AuthState state) {
                if (state is BikerSplashAlreadyUser) {
                  sl<AuthBloc>().getUserLocation().whenComplete(() {
                    if (sl<ProfileBloc>().profile.userName == null) {
                      sl<ProfileBloc>().add(BikerProfile());
                    }
                  });
                } else if (state is BikerSplashExpiredToken ||
                    state is BikerSplashNotUser) {
                  popALlAndPushPage(context, LogInScreen());
                }
              },
              builder: (BuildContext context, AuthState state) {
                return Stack(
                  children: <Widget>[
                    Container(
                      color: ColorManager.primary,
                    ),
                    Center(
                      child: ScaleTransition(
                        scale: _animation,
                        child: SvgPicture.asset(ImageAssets.logoWhite),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
