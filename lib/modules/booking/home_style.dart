import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Home layouts to compare. Same data and booking flow; only the order and
/// emphasis change.
enum HomeStyle {
  mix,
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
    HomeStyle.mix,
  );

  static Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_key);
    style.value = HomeStyle.values.firstWhere(
      (HomeStyle s) => s.name == saved,
      orElse: () => HomeStyle.mix,
    );
  }

  static Future<void> set(HomeStyle value) async {
    style.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}

/// The service this customer has booked most, from their finished washes.
/// Null until they have booked something, so the badge is never invented.
final ValueNotifier<String?> mostBookedServiceId = ValueNotifier<String?>(null);

/// The most frequent id; ties go to the one seen first, so to the latest wash.
String? mostFrequentId(Iterable<String?> ids) {
  final Map<String, int> counts = <String, int>{};
  for (final String? id in ids) {
    if (id != null) counts[id] = (counts[id] ?? 0) + 1;
  }
  String? best;
  for (final MapEntry<String, int> entry in counts.entries) {
    if (best == null || entry.value > counts[best]!) best = entry.key;
  }
  return best;
}
