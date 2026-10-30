import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/utilis/the_washer_observer.dart';
import 'package:thewhsherbiker/localization/translate_preferences.dart';
import 'package:thewhsherbiker/modules/notification/services/notification_service.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'app.dart';
import 'flavors.dart';

void main() async {
  F.appFlavor = Flavor.PRO;
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize service locator
  ServiceLocator().init();

  // Lock screen orientation
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  LocalizationDelegate.create(
          preferences: TranslatePreferences(),
          fallbackLocale: 'ar',
          supportedLocales: <String>['en', 'ar'])
      .then((LocalizationDelegate delegate) {
    Bloc.observer = TheWasherBlocObserver();
    runApp(LocalizedApp(delegate, App()));
  });
}
