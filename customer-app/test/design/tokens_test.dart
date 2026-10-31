import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/core/design/tokens.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('KColors', () {
    test('light palette matches the approved design system', () {
      const KColors c = KColors.light;
      expect(c.brand, const Color(0xFF543063));
      expect(c.brandLight, const Color(0xFF8E5BA6));
      expect(c.background, const Color(0xFFF2F2F7));
      expect(c.surface, const Color(0xFFFFFFFF));
      expect(c.text, const Color(0xFF1C1C1E));
      expect(c.textSecondary, const Color(0xFF6E6E73));
      expect(c.success, const Color(0xFF34C759));
      expect(c.warning, const Color(0xFFFF9500));
      expect(c.error, const Color(0xFFFF3B30));
    });

    testWidgets('of() follows the theme brightness on iOS', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      late KColors light, dark;
      await tester.pumpWidget(Column(children: <Widget>[
        Theme(
          data: ThemeData(brightness: Brightness.light),
          child: Builder(builder: (BuildContext c) {
            light = KColors.of(c);
            return const SizedBox();
          }),
        ),
        Theme(
          data: ThemeData(brightness: Brightness.dark),
          child: Builder(builder: (BuildContext c) {
            dark = KColors.of(c);
            return const SizedBox();
          }),
        ),
      ]));
      expect(identical(light, KColors.light), isTrue);
      expect(identical(dark, KColors.dark), isTrue);
      debugDefaultTargetPlatformOverride = null;
    });

    test('Android uses Material tonal surfaces and keeps the exact brand', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final KColors c = KColors.forBrightness(Brightness.light);
      expect(identical(c, KColors.materialLight), isTrue);
      expect(c.brand, const Color(0xFF543063));
      // Not Apple's grouped-background grey.
      expect(c.background, isNot(const Color(0xFFF2F2F7)));
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('KType', () {
    test('Android uses the Material 3 type scale', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(KType.largeTitle.fontSize, 32);
      expect(KType.title.fontSize, 22);
      expect(KType.title.fontWeight, FontWeight.w500);
      expect(KType.headline.fontSize, 16);
      expect(KType.body.fontSize, 16);
      expect(KType.subhead.fontSize, 14);
      expect(KType.footnote.fontSize, 12);
      expect(KType.caption.fontSize, 11);
      debugDefaultTargetPlatformOverride = null;
    });

    test('iOS uses the Apple type scale', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(KType.largeTitle.fontSize, 34);
      expect(KType.largeTitle.fontWeight, FontWeight.w800);
      expect(KType.title.fontSize, 22);
      expect(KType.title.fontWeight, FontWeight.w700);
      expect(KType.headline.fontSize, 17);
      expect(KType.headline.fontWeight, FontWeight.w600);
      expect(KType.body.fontSize, 17);
      expect(KType.subhead.fontSize, 15);
      expect(KType.footnote.fontSize, 13);
      expect(KType.caption.fontSize, 12);
      debugDefaultTargetPlatformOverride = null;
    });

    test('uses platform fonts (no fontFamily) and no baked-in colour', () {
      for (final TextStyle s in <TextStyle>[
        KType.largeTitle,
        KType.title,
        KType.headline,
        KType.body,
        KType.subhead,
        KType.footnote,
        KType.caption,
      ]) {
        expect(s.fontFamily, isNull);
        expect(s.color, isNull);
      }
    });
  });

  test('spacing, radii and tap target', () {
    expect(<double>[KSpace.xs, KSpace.s, KSpace.m, KSpace.l, KSpace.xl, KSpace.xxl, KSpace.xxxl],
        <double>[4, 8, 12, 16, 20, 24, 32]);
    expect(KSpace.tapTarget, 44);
    expect(KRadius.field, 14);
    expect(KRadius.card, 22);
    expect(KRadius.sheet, 34);
    expect(KRadius.dialog, 30);
  });

  testWidgets('motion is disabled when Reduce Motion is on', (WidgetTester tester) async {
    late Duration reduced, normal;
    await tester.pumpWidget(Column(children: <Widget>[
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(builder: (BuildContext c) {
          reduced = KMotion.of(c, KMotion.normal);
          return const SizedBox();
        }),
      ),
      MediaQuery(
        data: const MediaQueryData(),
        child: Builder(builder: (BuildContext c) {
          normal = KMotion.of(c, KMotion.normal);
          return const SizedBox();
        }),
      ),
    ]));
    expect(reduced, Duration.zero);
    expect(normal, const Duration(milliseconds: 300));
    expect(KMotion.fast, const Duration(milliseconds: 200));
    expect(KMotion.slow, const Duration(milliseconds: 400));
    expect(KMotion.curve, Curves.easeOutCubic);
  });
}
