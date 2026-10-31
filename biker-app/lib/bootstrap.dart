import 'package:thewhsherbiker/core/design/components/k_auth_scaffold.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/k_theme_mode.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/app.dart';
import 'package:thewhsherbiker/core/utilis/the_washer_observer.dart';
import 'package:thewhsherbiker/flavors.dart';
import 'package:thewhsherbiker/localization/translate_preferences.dart';
import 'package:thewhsherbiker/modules/notification/services/notification_service.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// Shared startup for every flavor entry point.
Future<void> bootstrap(Flavor flavor, {required String fallbackLocale}) async {
  F.appFlavor = flavor;
  WidgetsFlutterBinding.ensureInitialized();
  // Logs can contain tokens and order/payment data: silence them in release.
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) {};

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  KAuthScaffold.headerPhoto = 'assets/images/photo_onboard_three.png';
  ServiceLocator().init();

  // All orientations: required for foldables (folded/unfolded) and large
  // screens, where Android 16 ignores orientation locks anyway.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await KThemeMode.load();
  final LocalizationDelegate delegate = await LocalizationDelegate.create(
    preferences: TranslatePreferences(),
    fallbackLocale: fallbackLocale,
    supportedLocales: <String>['en', 'ar'],
  );
  Bloc.observer = TheWasherBlocObserver();
  runApp(LocalizedApp(delegate, App()));
}
