import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/core/design/kleano_theme.dart';

BorderRadius? _radius(ShapeBorder? shape) => switch (shape) {
      RoundedSuperellipseBorder(:final BorderRadiusGeometry borderRadius) =>
        borderRadius.resolve(TextDirection.ltr),
      RoundedRectangleBorder(:final BorderRadiusGeometry borderRadius) =>
        borderRadius.resolve(TextDirection.ltr),
      _ => null,
    };

void main() {
  group('light theme', () {
    final ThemeData t = kleanoTheme(brightness: Brightness.light);

    test('uses Material 3 with the brand and background colours', () {
      expect(t.useMaterial3, isTrue);
      expect(t.colorScheme.brightness, Brightness.light);
      expect(t.colorScheme.primary, const Color(0xFF543063));
      expect(t.scaffoldBackgroundColor, isNot(const Color(0xFFF2F2F7)));
    });

    test('iOS uses Apple system fonts, not the old bundled Roboto/Cairo', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final ThemeData ios = kleanoTheme(brightness: Brightness.light);
        for (final TextStyle? s in <TextStyle?>[
          ios.textTheme.bodyLarge,
          ios.textTheme.titleLarge,
          ios.textTheme.displaySmall,
        ]) {
          expect(s?.fontFamily, isNot(anyOf('Roboto', 'Cairo')));
        }
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('Android uses the system font, never the bundled Cairo', () {
      expect(t.textTheme.bodyLarge?.fontFamily, isNot('Cairo'));
      expect(t.textTheme.displaySmall?.fontSize, 32);
      expect(t.textTheme.bodyLarge?.fontSize, 16);
    });

    test('buttons are capsules at least 44pt tall', () {
      final ButtonStyle s = t.filledButtonTheme.style!;
      expect(s.shape!.resolve(<WidgetState>{}), isA<StadiumBorder>());
      expect(s.minimumSize!.resolve(<WidgetState>{})!.height, greaterThanOrEqualTo(44));
    });

    test('Android fields are outlined with radius 14 and a 2px brand focus border', () {
      final InputDecorationThemeData d = t.inputDecorationTheme;
      expect(d.filled, isFalse);
      final InputBorder? focused = d.focusedBorder;
      expect(focused, isA<OutlineInputBorder>());
      expect((focused! as OutlineInputBorder).borderRadius, BorderRadius.circular(14));
      expect(focused.borderSide.width, 2);
      expect(focused.borderSide.color, const Color(0xFF543063));
    });

    test('cards are radius 22 and sheets radius 34', () {
      expect(_radius(t.cardTheme.shape), BorderRadius.circular(22));
      expect(_radius(t.bottomSheetTheme.shape)?.topLeft, const Radius.circular(34));
    });
  });

  test('dark theme', () {
    final ThemeData t = kleanoTheme(brightness: Brightness.dark);
    expect(t.colorScheme.brightness, Brightness.dark);
    expect(t.colorScheme.primary, const Color(0xFFB88CD0));
  });

  test('iOS is Apple: grouped background, filled fields, centred titles', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      final ThemeData ios = kleanoTheme(brightness: Brightness.light);
      expect(ios.scaffoldBackgroundColor, const Color(0xFFF2F2F7));
      expect(ios.inputDecorationTheme.filled, isTrue);
      expect(ios.appBarTheme.centerTitle, isTrue);
      expect(kleanoTheme(brightness: Brightness.dark).scaffoldBackgroundColor,
          Colors.black);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  test('Android is Material: start-aligned titles', () {
    expect(kleanoTheme(brightness: Brightness.light).appBarTheme.centerTitle,
        isFalse);
  });
}
