import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

/// Single AppsFlyer entry point (SDK 7).
///
/// SDK 7 sends nothing until `start()`, which must run once per foreground
/// cycle; the session-ready listener takes care of that. Events are
/// fire-and-forget so analytics can never block navigation.
class AppsFlyerService {
  AppsFlyerService._();

  static const String _devKey = 'vTBNf24bS4fxnsgxuRE7nK';
  static const String _appleAppId = '6744847373';

  static final AppsFlyerSdk _sdk = AppsFlyerSdk.instance;
  static Future<void>? _initializing;

  static Future<void> init() => _initializing ??= _init();

  static Future<void> _init() async {
    try {
      await _sdk.enableDebug(kDebugMode);
      await _sdk.init(devKey: _devKey, appId: _appleAppId);
      await _sdk.registerSessionReadyListener(() => _sdk.start());
    } catch (e) {
      debugPrint('AppsFlyer init failed: $e');
    }
  }

  static void logEvent(String name, [Map<String, dynamic>? values]) {
    init().then((_) => _sdk.logEvent(name, eventValues: values)).catchError(
        (Object e) => debugPrint('AppsFlyer event "$name" failed: $e'));
  }
}
