import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The appearance the user picked in Settings. Light until they choose, and
/// remembered on this device. iOS is told too, so native glass follows the app
/// rather than the phone.
abstract final class KThemeMode {
  static const String _key = 'kleano_theme_mode';
  static const MethodChannel _channel = MethodChannel('kleano/appearance');

  static final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  static Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_key);
    mode.value = ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == saved,
      orElse: () => ThemeMode.light,
    );
    await _tellNative();
  }

  static Future<void> set(ThemeMode value) async {
    mode.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
    await _tellNative();
  }

  static Future<void> _tellNative() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _channel.invokeMethod<void>('set', mode.value.name);
    } on PlatformException catch (_) {
      // The app still follows the choice; only native glass would not.
    } on MissingPluginException catch (_) {
      // Tests have no native side.
    }
  }
}
