import 'dart:async' as BlocOverrides;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/app.dart';
import 'package:thewasher/flavors.dart';
import 'package:thewasher/localization/translate_preferences.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() {
  F.appFlavor = Flavor.PRO;

  return BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Initialize timezone database for scheduled local notifications
      tz.initializeTimeZones();

      ServiceLocator().init();
      await Firebase.initializeApp();

      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      final LocalizationDelegate delegate = await LocalizationDelegate.create(
        preferences: TranslatePreferences(),
        fallbackLocale: 'en',
        supportedLocales: <String>['en', 'ar'],
      );

      runApp(LocalizedApp(delegate, App()));
    },
  );
}
