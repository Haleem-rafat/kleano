import 'package:flutter/foundation.dart';

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
