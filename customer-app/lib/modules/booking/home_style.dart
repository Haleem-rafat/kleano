import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Home layouts to compare. Same data and booking flow; only the order and
/// emphasis change.
enum HomeStyle {
  current,
  photoHero,
  serviceGrid,
  quickRebook,
  serviceFirst,
  liveStatus,
  offersFirst,
}

/// The chosen Home layout, remembered on this device.
abstract final class HomeStyleSetting {
  static const String _key = 'kleano_home_style';

  static final ValueNotifier<HomeStyle> style = ValueNotifier<HomeStyle>(
    HomeStyle.current,
  );

  static Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_key);
    style.value = HomeStyle.values.firstWhere(
      (HomeStyle s) => s.name == saved,
      orElse: () => HomeStyle.current,
    );
  }

  static Future<void> set(HomeStyle value) async {
    style.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}
