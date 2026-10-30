import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/app.dart';
import 'package:thewasher/core/utilis/the_washer_observer.dart';
import 'package:thewasher/flavors.dart';
import 'package:thewasher/localization/translate_preferences.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  // ChuckerFlutter.showOnRelease = true;

  F.appFlavor = Flavor.DEV;

  WidgetsFlutterBinding.ensureInitialized();
  // Initialize timezone database for scheduled local notifications
  tz.initializeTimeZones();

  ServiceLocator().init();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  LocalizationDelegate.create(
          preferences: TranslatePreferences(),
          fallbackLocale: 'en',
          supportedLocales: <String>['en', 'ar'])
      .then((LocalizationDelegate delegate) {
    Bloc.observer = TheWasherBlocObserver();
    runApp(LocalizedApp(delegate, App()));
  });
}
