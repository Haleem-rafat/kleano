import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/modules/profile/widgets/upload_user_photo.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/singleton.dart';

void main() {
  final GeneralSingleton singleton = GeneralSingleton();

  Future<void> pump(WidgetTester t, String photo) => t.pumpWidget(
    MaterialApp(
      theme: kleanoTheme(brightness: Brightness.light),
      home: Scaffold(body: UserPhoto(userPhoto: photo, isEdit: false)),
    ),
  );

  setUp(() {
    singleton.userImage = null;
    singleton.characterUserName = null;
  });

  testWidgets('a photo from the server shows without a picked image', (
    WidgetTester t,
  ) async {
    await pump(t, 'https://example.com/me.jpg');
    expect(t.takeException(), isNull);
    expect(find.byType(ImageShared), findsOneWidget);
  });

  testWidgets('no photo shows the initial', (WidgetTester t) async {
    singleton.characterUserName = 'A';
    await pump(t, 'null');
    expect(t.takeException(), isNull);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('no photo and no initial does not crash', (WidgetTester t) async {
    await pump(t, 'null');
    expect(t.takeException(), isNull);
    expect(find.byType(ImageShared), findsNothing);
  });

  testWidgets('no stored initial falls back to the name', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        theme: kleanoTheme(brightness: Brightness.light),
        home: const Scaffold(
          body: UserPhoto(userPhoto: 'null', isEdit: false, name: 'test'),
        ),
      ),
    );
    expect(find.text('T'), findsOneWidget);
  });

  testWidgets('a picked image is shown from its file', (WidgetTester t) async {
    singleton.userImage = XFile('/tmp/me.jpg');
    await pump(t, 'null');
    expect(t.takeException(), isNull);
    expect(find.byType(ImageShared), findsNothing);
    expect(find.byType(DecoratedBox), findsWidgets);
  });
}
