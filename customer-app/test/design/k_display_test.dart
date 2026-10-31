import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_segmented.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/kleano_theme.dart';

Widget host(
  Widget child, {
  TextDirection dir = TextDirection.ltr,
  double width = 390,
  double textScale = 1,
}) => MaterialApp(
  theme: kleanoTheme(brightness: Brightness.light),
  home: Directionality(
    textDirection: dir,
    child: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: Center(
          child: SizedBox(width: width - 32, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets('status chip uses the darker success shade for its label', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(
      host(const KStatusChip(label: 'Completed', status: KStatus.success)),
    );
    expect(
      t.widget<Text>(find.text('Completed')).style!.color,
      const Color(0xFF1F8A3D),
    );
  });

  testWidgets('status chip warning and error label shades', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(
      host(
        const Column(
          children: <Widget>[
            KStatusChip(label: 'On the way', status: KStatus.warning),
            KStatusChip(label: 'Cancelled', status: KStatus.error),
          ],
        ),
      ),
    );
    expect(
      t.widget<Text>(find.text('On the way')).style!.color,
      const Color(0xFFC25E00),
    );
    expect(
      t.widget<Text>(find.text('Cancelled')).style!.color,
      const Color(0xFFD70015),
    );
  });

  testWidgets('segmented control is Cupertino on iOS and calls back', (
    WidgetTester t,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    String? picked;
    await t.pumpWidget(
      host(
        KSegmented<String>(
          segments: const <String, String>{
            'active': 'Active',
            'done': 'Completed',
          },
          selected: 'active',
          onChanged: (String v) => picked = v,
        ),
      ),
    );
    expect(
      find.byType(CupertinoSlidingSegmentedControl<String>),
      findsOneWidget,
    );
    await t.tap(find.text('Completed'));
    await t.pumpAndSettle();
    expect(picked, 'done');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('segmented control is a Material SegmentedButton on Android', (
    WidgetTester t,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    String? picked;
    await t.pumpWidget(
      host(
        KSegmented<String>(
          segments: const <String, String>{
            'active': 'Active',
            'done': 'Completed',
          },
          selected: 'active',
          onChanged: (String v) => picked = v,
        ),
      ),
    );
    expect(find.byType(SegmentedButton<String>), findsOneWidget);
    await t.tap(find.text('Completed'));
    await t.pumpAndSettle();
    expect(picked, 'done');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('list row is at least 44pt and its chevron mirrors in RTL', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(
      host(KListRow(title: 'Settings', showChevron: true, onTap: () {})),
    );
    expect(t.getSize(find.byType(KListRow)).height, greaterThanOrEqualTo(44));
    final Icon ltr = t.widget(
      find.byKey(const ValueKey<String>('k-list-row-chevron')),
    );
    expect(ltr.icon!.matchTextDirection, isTrue);

    await t.pumpWidget(
      host(
        KListRow(title: 'الإعدادات', showChevron: true, onTap: () {}),
        dir: TextDirection.rtl,
      ),
    );
    final Rect chevron = t.getRect(
      find.byKey(const ValueKey<String>('k-list-row-chevron')),
    );
    final Rect title = t.getRect(find.text('الإعدادات'));
    expect(chevron.center.dx, lessThan(title.center.dx));
  });

  testWidgets('error state retry calls back', (WidgetTester t) async {
    int retries = 0;
    await t.pumpWidget(
      host(KErrorState(message: 'No connection', onRetry: () => retries++)),
    );
    await t.tap(find.byKey(const ValueKey<String>('k-error-retry')));
    expect(retries, 1);
  });

  testWidgets('everything fits at 320pt and text scale 1.35', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(
      host(
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const KCard(
                child: Text(
                  '#KL-20418 · Toyota Camry · ABC 1234 · Al Olaya, Riyadh',
                ),
              ),
              const KStatusChip(
                label: 'On the way to the customer',
                status: KStatus.warning,
              ),
              KListRow(
                title: 'A very long settings row title that must wrap',
                subtitle: 'And a subtitle that is also quite long',
                showChevron: true,
                onTap: () {},
              ),
              const KEmptyState(
                title: 'No orders yet',
                message: 'New requests will appear here',
              ),
              const KLoadingState(),
            ],
          ),
        ),
        width: 320,
        textScale: 1.35,
      ),
    );
    expect(t.takeException(), isNull);
  });

  group('KSkeleton', () {
    Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: child),
      ),
    );

    for (final (String name, Widget skeleton) in <(String, Widget)>[
      ('list', const KSkeleton.list()),
      ('grid', const KSkeleton.grid()),
      ('details', const KSkeleton.details()),
    ]) {
      testWidgets('$name fits a small window and pulses', (
        WidgetTester t,
      ) async {
        t.view.physicalSize = const Size(320, 300);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(host(skeleton));
        expect(t.takeException(), isNull);
        expect(t.hasRunningAnimations, isTrue);
      });
    }

    testWidgets('holds still with reduced motion', (WidgetTester t) async {
      await t.pumpWidget(host(const KSkeleton.list(), reduceMotion: true));
      expect(t.hasRunningAnimations, isFalse);
    });
  });
}
