import 'package:flutter/material.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class Routes {
  static const String splashRoute = "/";
  static const String loginRoute = "/login";
  static const String registerRoute = "/register";
  static const String forgetPasswordRoute = "/forgetPassword";
  static const String onBoardingRoute = "/onBoarding";
  static const String mainRoute = "/main";
  static const String storeDetailsRoute = "/storeDetails";
}

class RouteGenerator {
  /*static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute<void>(builder: (_) => const MainMoviesScreen());
         default:
        return undefinedRoute();
    }
  }*/

  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(
                title: const Text(AppStrings.noRouteFound),
              ),
              body: const Center(
                child: Text(AppStrings.noInternetError),
              ),
            ));
  }
}
