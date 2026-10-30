import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/about_us/bloc/about_us_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/points/bloc/point_bloc.dart';
import 'package:thewasher/modules/profile/blocs/delete_user_account/delete_user_account_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/modules/splash/splash_two_screen.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

import 'flavors.dart';
import 'package:thewasher/layout/services/notification_manager_service.dart';

final GlobalKey<NavigatorState> navigatorKeyAlice = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationManagerService().initialize(context);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    LocalizationDelegate localizationDelegate =
        LocalizedApp.of(context).delegate;
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
        BlocProvider<DeleteUserAccountBloc>(
          create: (BuildContext context) => DeleteUserAccountBloc(),
        ),
        BlocProvider<GetUserProfileBloc>(
          create: (BuildContext context) => sl<GetUserProfileBloc>(),
        ),
        BlocProvider<UpdateProfileBloc>(
          create: (BuildContext context) => UpdateProfileBloc(),
        ),
        BlocProvider<VehiclesBloc>(
          create: (BuildContext context) => sl<VehiclesBloc>(),
        ),
        BlocProvider<CarsBloc>(
          create: (_) => CarsBloc(),
        ),
        BlocProvider<LocationBloc>(
          create: (BuildContext context) => sl<LocationBloc>(),
        ),
        BlocProvider<PromoBloc>(
          create: (BuildContext context) => sl<PromoBloc>(),
        ),
        BlocProvider<PlansAndSubscriptionBloc>(
          create: (BuildContext context) => sl<PlansAndSubscriptionBloc>(),
        ),
        BlocProvider<OffersBloc>(
          create: (BuildContext context) => sl<OffersBloc>(),
        ),
        BlocProvider<BookingOrderBloc>(
          create: (BuildContext context) => sl<BookingOrderBloc>(),
        ),
        BlocProvider<MyBookingBloc>(
          create: (BuildContext context) => sl<MyBookingBloc>(),
        ),
        BlocProvider<SocketBloc>(
          create: (BuildContext context) => sl<SocketBloc>(),
        ),
        BlocProvider<NotificationsBloc>(
          create: (BuildContext context) => sl<NotificationsBloc>(),
        ),
        BlocProvider<PointBloc>(
          create: (BuildContext context) => sl<PointBloc>(),
        ),
        BlocProvider<AboutUsBloc>(
          create: (BuildContext context) => sl<AboutUsBloc>(),
        ),
      ],
      child: LocalizationProvider(
        state: LocalizationProvider.of(context).state,
        child: AdaptiveScreenUtil(
            builder: (_) {
              return MaterialApp(
                navigatorKey: navigatorKeyAlice,
                theme: kleanoTheme(brightness: Brightness.light),
                darkTheme: kleanoTheme(brightness: Brightness.dark),
                // Light until every screen uses the design tokens.
                themeMode: ThemeMode.light,
                builder: (BuildContext context, Widget? navigator) {
                  return BackdropGroup(
                    child: LiquidGlassTheme.clampTextScale(context,
                        FoldScope(child: SystemBarInset(child: navigator!))),
                  );
                },
                debugShowCheckedModeBanner: false,
                title: F.title,
                home: const SplashTwoScreen(),
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  localizationDelegate
                ],
                supportedLocales: localizationDelegate.supportedLocales,
                locale: localizationDelegate.currentLocale,
              );
            }),
      ),
    );
  }
}
