import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/core/design/components/k_auth_scaffold.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/core/design/liquid_glass.dart';

const Key primaryKey = ValueKey<String>('primary');

Widget app({
  TextDirection dir = TextDirection.ltr,
  bool showBack = false,
  String title = 'Welcome back',
  bool systemBarInset = false,
}) {
  final Widget scaffold = KAuthScaffold(
    title: title,
    subtitle: 'Log in to start receiving wash requests',
    showBack: showBack,
    onBack: () {},
    badge: 'Biker',
    primaryAction: KButton(key: primaryKey, label: 'Log in', onPressed: () {}),
    secondaryAction: KButton(
        label: 'Forgot password?', variant: KButtonVariant.text, onPressed: () {}),
    children: const <Widget>[
      KTextField(label: 'Username'),
      SizedBox(height: 12),
      KTextField(label: 'Password', obscure: true),
    ],
  );
  return MaterialApp(
    theme: kleanoTheme(brightness: Brightness.light),
    builder: (BuildContext context, Widget? child) => Directionality(
      textDirection: dir,
      child: systemBarInset ? SystemBarInset(child: child!) : child!,
    ),
    home: scaffold,
  );
}

void size(WidgetTester t, Size s) {
  t.view.devicePixelRatio = 3;
  t.view.physicalSize = s * 3;
  addTearDown(t.view.reset);
}

void main() {
  testWidgets('primary action stays fully visible with the keyboard open on a small phone',
      (WidgetTester t) async {
    size(t, const Size(375, 667));
    t.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
    await t.pumpWidget(app());
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    final Rect button = t.getRect(find.byKey(primaryKey));
    expect(button.bottom, lessThanOrEqualTo(667 - 300));
    expect(button.top, greaterThan(0));
  });

  testWidgets('primary action sits above the home indicator without a keyboard',
      (WidgetTester t) async {
    size(t, const Size(402, 874));
    t.view.padding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3);
    await t.pumpWidget(app());
    await t.pumpAndSettle();
    expect(t.getRect(find.byKey(primaryKey)).bottom, lessThanOrEqualTo(874 - 34));
  });

  testWidgets('back button sits on the leading side and mirrors in Arabic',
      (WidgetTester t) async {
    size(t, const Size(402, 874));
    await t.pumpWidget(app(showBack: true));
    await t.pumpAndSettle();
    final Finder back = find.byType(GlassBackButton);
    expect(t.getCenter(back).dx, lessThan(201));

    await t.pumpWidget(app(showBack: true, dir: TextDirection.rtl));
    await t.pumpAndSettle();
    expect(t.getCenter(back).dx, greaterThan(201));
  });

  testWidgets('iPhone Duo outer display: nothing under the side status bar',
      (WidgetTester t) async {
    size(t, const Size(466, 678));
    t.view.padding = const FakeViewPadding(top: 20 * 3, right: 90 * 3);
    await t.pumpWidget(app(systemBarInset: true));
    await t.pumpAndSettle();
    expect(t.getRect(find.text('Welcome back')).right, lessThanOrEqualTo(466 - 90));
    expect(t.getRect(find.byKey(primaryKey)).right, lessThanOrEqualTo(466 - 90));
  });

  testWidgets('long title at text scale 1.35 wraps without overflow', (WidgetTester t) async {
    size(t, const Size(375, 667));
    await t.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.35)),
      child: app(title: 'مرحبًا بعودتك إلى تطبيق كلينو لغسيل السيارات المتنقل'),
    ));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
}
