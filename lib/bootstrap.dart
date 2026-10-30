import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/app.dart';
import 'package:thewasher/core/services/appsflyer_service.dart';
import 'package:thewasher/core/utilis/the_washer_observer.dart';
import 'package:thewasher/flavors.dart';
import 'package:thewasher/localization/translate_preferences.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Shared startup for every flavor entry point.
Future<void> bootstrap(Flavor flavor) async {
  F.appFlavor = flavor;
  WidgetsFlutterBinding.ensureInitialized();
  // Logs can contain tokens and order/payment data: silence them in release.
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) {};
  // Timezone database for scheduled local notifications.
  tz.initializeTimeZones();

  ServiceLocator().init();
  await Firebase.initializeApp();
  AppsFlyerService.init();

  // All orientations: required for foldables (folded/unfolded) and large
  // screens, where Android 16 ignores orientation locks anyway.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final LocalizationDelegate delegate = await LocalizationDelegate.create(
    preferences: TranslatePreferences(),
    fallbackLocale: 'en',
    supportedLocales: <String>['en', 'ar'],
  );
  if (flavor == Flavor.DEV) Bloc.observer = TheWasherBlocObserver();
  runApp(LocalizedApp(delegate, App()));
}
