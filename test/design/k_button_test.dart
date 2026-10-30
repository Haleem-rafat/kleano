import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/core/design/liquid_glass.dart';

Widget host(Widget child, {double textScale = 1, double width = 390}) => MaterialApp(
      theme: kleanoTheme(brightness: Brightness.light),
      home: MediaQuery(
        data: MediaQueryData(
            size: Size(width, 800), textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Center(child: SizedBox(width: width - 40, child: child)),
        ),
      ),
    );

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('Android', () {
    testWidgets('primary renders a FilledButton with the label', (WidgetTester t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await t.pumpWidget(host(KButton(label: 'Log in', onPressed: () {})));
      expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('secondary renders a tonal FilledButton', (WidgetTester t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await t.pumpWidget(host(KButton(
          label: 'Details', variant: KButtonVariant.secondary, onPressed: () {})));
      expect(find.byKey(const ValueKey<String>('k-button-secondary')), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('loading shows progress and ignores taps', (WidgetTester t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      int taps = 0;
      await t.pumpWidget(
          host(KButton(label: 'Log in', loading: true, onPressed: () => taps++)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await t.tap(find.byType(KButton), warnIfMissed: false);
      expect(taps, 0);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('long label at text scale 1.35 on a 320pt screen does not overflow',
        (WidgetTester t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await t.pumpWidget(host(
          KButton(label: 'سجّل الدخول لتبدأ استقبال طلبات الغسيل الآن', onPressed: () {}),
          textScale: 1.35,
          width: 320));
      expect(t.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('iOS', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform_views, (MethodCall _) async => null);
    });

    testWidgets('primary is Apple prominent glass', (WidgetTester t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await t.pumpWidget(host(KButton(label: 'Log in', onPressed: () {})));
      final NativeGlassButton b = t.widget(find.byType(NativeGlassButton));
      expect(b.style, GlassButtonStyle.prominent);
      expect(b.title, 'Log in');
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('secondary is Apple glass', (WidgetTester t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await t.pumpWidget(host(KButton(
          label: 'Details', variant: KButtonVariant.secondary, onPressed: () {})));
      expect(t.widget<NativeGlassButton>(find.byType(NativeGlassButton)).style,
          GlassButtonStyle.glass);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('loading shows the iOS activity indicator', (WidgetTester t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await t.pumpWidget(host(KButton(label: 'Log in', loading: true, onPressed: () {})));
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(NativeGlassButton), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
