import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';

/// Logical screen sizes the apps must handle without overflow.
const Map<String, Size> devices = <String, Size>{
  'iPhone SE': Size(375, 667),
  'iPhone 17 Pro portrait': Size(402, 874),
  'iPhone 17 Pro landscape': Size(874, 402),
  'Foldable folded (cover)': Size(375, 820),
  'Foldable unfolded': Size(834, 1012),
  'Foldable unfolded rotated': Size(1012, 834),
  'iPhone Duo folded (outer)': Size(466, 678),
  'iPhone Duo unfolded': Size(951, 669),
  'iPhone Duo unfolded portrait': Size(669, 951),
  'iPad': Size(1024, 1366),
};

Widget shell({TextDirection direction = TextDirection.ltr}) {
  return AdaptiveScreenUtil(
    builder: (_) => MaterialApp(
      theme: LiquidGlassTheme.apply(ThemeData(), primary: const Color(0xFF543063)),
      builder: (BuildContext context, Widget? child) => Directionality(
        textDirection: direction,
        child: BackdropGroup(child: child!),
      ),
      home: Scaffold(
        extendBody: true,
        appBar: const GlassAppBar(title: Text('Kleano')),
        body: ListView(
          padding: EdgeInsets.all(16.w),
          children: <Widget>[
            for (int i = 0; i < 6; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: LiquidGlass(
                  padding: EdgeInsets.all(16.r),
                  child: Text('Card $i', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
          ],
        ),
        bottomNavigationBar: GlassTabBar(
          currentIndex: 1,
          onTap: (_) {},
          items: <GlassTabItem>[
            for (final String label in <String>[
              'Home', 'Bookings', 'Plans', 'Vehicles', 'Profile',
            ])
              GlassTabItem(
                label: label,
                iconBuilder: (bool s, Color c) => Icon(Icons.circle, color: c),
              ),
          ],
        ),
      ),
    ),
  );
}

void setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = size * 3;
}

void main() {
  for (final MapEntry<String, Size> device in devices.entries) {
    for (final TextDirection dir in TextDirection.values) {
      testWidgets('${device.key} (${dir.name}) lays out without overflow',
          (WidgetTester tester) async {
        setSize(tester, device.value);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(shell(direction: dir));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        if (AdaptiveScreenUtil.isWide(device.value)) {
          // Wide: one uniform, clamped scale for both axes (no stretching).
          expect(ScreenUtil().scaleWidth, closeTo(ScreenUtil().scaleHeight, 1e-9));
          expect(ScreenUtil().scaleWidth,
              inInclusiveRange(AdaptiveScreenUtil.minScale, AdaptiveScreenUtil.maxScale));
        } else {
          // Compact: original design scaling, so 375.w is the full width.
          expect(375.w, closeTo(device.value.width, 1e-6));
        }
        // Full-width sizes always match the real screen.
        expect(1.sw, device.value.width);
        // Tab bar stays a centred capsule on wide screens.
        final Size bar = tester.getSize(find.descendant(
            of: find.byType(GlassTabBar), matching: find.byType(LiquidGlass)));
        expect(bar.width, lessThanOrEqualTo(560));
      });
    }
  }

  testWidgets('fold / unfold / rotate at runtime re-scales the UI',
      (WidgetTester tester) async {
    addTearDown(tester.view.reset);
    final List<double> scales = <double>[];
    for (final Size size in <Size>[
      devices['Foldable folded (cover)']!,
      devices['Foldable unfolded']!,
      devices['Foldable unfolded rotated']!,
      devices['Foldable folded (cover)']!,
    ]) {
      setSize(tester, size);
      await tester.pumpWidget(shell());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      scales.add(ScreenUtil().scaleWidth);
    }
    // Back to the same state after folding again.
    expect(scales.first, scales.last);
  });

  testWidgets('reduce transparency (high contrast) renders opaque glass',
      (WidgetTester tester) async {
    setSize(tester, devices['iPhone 17 Pro portrait']!);
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(highContrast: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(shell());
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('iPhone Duo: tab bar stays in one pane, never across the fold',
      (WidgetTester tester) async {
    const Size size = Size(951, 669);
    setSize(tester, size);
    addTearDown(tester.view.reset);
    // 40pt division in the middle, as reported by reservedRegions(.division).
    const Rect fold = Rect.fromLTWH(455.5, 0, 40, 669);
    tester.view.displayFeatures = const <ui.DisplayFeature>[
      ui.DisplayFeature(
        bounds: fold,
        type: ui.DisplayFeatureType.hinge,
        state: ui.DisplayFeatureState.postureFlat,
      ),
    ];

    for (final TextDirection dir in TextDirection.values) {
      await tester.pumpWidget(shell(direction: dir));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final Rect bar = tester.getRect(find.descendant(
          of: find.byType(GlassTabBar), matching: find.byType(LiquidGlass)));
      expect(bar.overlaps(fold), isFalse, reason: 'tab bar crosses the fold');
      // Leading pane first: left in LTR, right in RTL.
      if (dir == TextDirection.ltr) {
        expect(bar.right, lessThanOrEqualTo(fold.left));
      } else {
        expect(bar.left, greaterThanOrEqualTo(fold.right));
      }
    }
  });

  testWidgets('iPhone Duo outer display: content stays clear of the side status bar',
      (WidgetTester tester) async {
    setSize(tester, const Size(466, 678));
    addTearDown(tester.view.reset);
    // The outer display reports its vertical status bar as a right inset.
    tester.view.padding = const FakeViewPadding(top: 3 * 20, right: 3 * 90);
    late Rect body;
    await tester.pumpWidget(MaterialApp(
      builder: (BuildContext context, Widget? child) =>
          SystemBarInset(child: child!),
      home: Builder(builder: (BuildContext context) {
        return const Scaffold(body: SizedBox.expand(key: Key('page')));
      }),
    ));
    body = tester.getRect(find.byKey(const Key('page')));
    expect(body.right, lessThanOrEqualTo(466 - 90));
    expect(tester.takeException(), isNull);
  });

  testWidgets('regular width and wider than tall shows the glass sidebar layout',
      (WidgetTester tester) async {
    for (final Size size in <Size>[const Size(951, 669), const Size(669, 951)]) {
      setSize(tester, size);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (BuildContext context) {
          final bool sidebar = isRegularWidth(context) &&
              MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;
          final List<GlassTabItem> items = <GlassTabItem>[
            for (final String l in <String>['Home', 'Bookings', 'Profile'])
              GlassTabItem(
                  label: l, iconBuilder: (bool s, Color c) => Icon(Icons.circle, color: c)),
          ];
          return Scaffold(
            body: sidebar
                ? Row(children: <Widget>[
                    GlassSidebar(items: items, currentIndex: 0, onTap: (_) {}),
                    const Expanded(child: SizedBox.expand()),
                  ])
                : const SizedBox.expand(),
            bottomNavigationBar: sidebar
                ? null
                : GlassTabBar(items: items, currentIndex: 0, onTap: (_) {}),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final bool wide = size.width > size.height;
      // Unfolded wide: sidebar; unfolded portrait keeps the bottom bar (Apple).
      expect(find.byType(GlassSidebar), wide ? findsOneWidget : findsNothing);
      expect(find.byType(GlassTabBar), wide ? findsNothing : findsOneWidget);
    }
  });
}
