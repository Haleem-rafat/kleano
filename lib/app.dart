import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/theme_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/order/bloc/order_bloc.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/splash/splash_screen.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

import 'flavors.dart';
import 'modules/Auth/bloc/phone_auth/phone_number_verification_cubit.dart';
final GlobalKey<NavigatorState> navigatorKeyAlice = GlobalKey<NavigatorState>();
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    LocalizationDelegate localizationDelegate =
        LocalizedApp.of(context).delegate;
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => sl<AuthBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (BuildContext context) => sl<ProfileBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (BuildContext context) => sl<HomeBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (BuildContext context) => sl<NotificationBloc>(),
        ),
        BlocProvider<OrderBloc>(
          create: (BuildContext context) => sl<OrderBloc>(),
        ),
       
        BlocProvider<PhoneNumberVerificationCubit>(
          create: (_) => PhoneNumberVerificationCubit(),
        ),
      ],
      child: LocalizationProvider(
        state: LocalizationProvider.of(context).state,
        child: AdaptiveScreenUtil(
          builder: (_) {
            return MaterialApp(
              navigatorKey: navigatorKeyAlice,
              builder: (BuildContext context, Widget? navigator) {
                final String lang = Localizations.localeOf(context).languageCode;
                return Theme(
                  data: LiquidGlassTheme.apply(
                    getApplicationTheme(lang),
                    primary: ColorManager.primary,
                  ),
                  child: BackdropGroup(
                    child: LiquidGlassTheme.clampTextScale(
                          context, FoldScope(child: SystemBarInset(child: navigator!))),
                  ),
                );
              },
              debugShowCheckedModeBanner: false,
              title: F.title,
              home: SplashScreen(),
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                localizationDelegate
              ],
              supportedLocales: localizationDelegate.supportedLocales,
              locale: localizationDelegate.currentLocale,
            );
          },
        ),
      ),
    );
  }
}
