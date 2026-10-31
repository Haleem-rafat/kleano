import 'package:thewasher/api/shared.dart';

class MultilingualHelper {
  static String? parseMultilingualField(dynamic json) {
    if (json == null) return null;

    if (json is String) {
      return json;
    }

    if (json is Map<String, dynamic>) {
      final lang = AppShared.lang;
      return json[lang] as String? ??
          json['en'] as String? ??
          json['ar'] as String?;
    }

    return null;
  }

  static List<String>? parseMultilingualList(dynamic json) {
    if (json == null) return null;

    if (json is List) {
      final List<String> result = [];
      for (var item in json) {
        final parsed = parseMultilingualField(item);
        if (parsed != null) {
          result.add(parsed);
        }
      }
      return result.isEmpty ? null : result;
    }

    final parsed = parseMultilingualField(json);
    return parsed != null ? [parsed] : null;
  }

  static Map<String, String>? getMultilingualObject(dynamic json) {
    if (json == null) return null;

    if (json is Map<String, dynamic>) {
      return {
        'ar': json['ar'] as String? ?? '',
        'en': json['en'] as String? ?? '',
      };
    }

    return null;
  }
}
