import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/modules/my_booking/widgets/wash_photos.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: <String>['en', 'ar'],
    );
  });

  Future<void> pump(WidgetTester t, {String? before, String? after}) =>
      t.pumpWidget(
        MaterialApp(
          theme: kleanoTheme(brightness: Brightness.light),
          home: Scaffold(
            body: WashPhotos(before: before, after: after),
          ),
        ),
      );

  testWidgets('nothing from the backend shows nothing', (t) async {
    await pump(t, before: '', after: null);
    expect(find.byType(ImageShared), findsNothing);
  });

  testWidgets('only the photo that exists is shown', (t) async {
    await pump(t, before: 'https://example.com/b.jpg');
    expect(find.byType(ImageShared), findsOneWidget);
  });

  testWidgets('before and after sit side by side', (t) async {
    await pump(
      t,
      before: 'https://example.com/b.jpg',
      after: 'https://example.com/a.jpg',
    );
    expect(t.takeException(), isNull);
    expect(find.byType(ImageShared), findsNWidgets(2));
  });
}
