import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/notifications/screens/guest_notification_screen.dart';
import 'package:thewasher/modules/profile/screens/profile_guest_view/profile_guest_view.dart';
import 'package:thewasher/modules/profile/widgets/wallet_topup_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: <String>['en', 'ar'],
    );
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      LocalizedApp(
        delegate,
        AdaptiveScreenUtil(
          builder: (_) => MaterialApp(
            theme: kleanoTheme(brightness: Brightness.light),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[delegate],
            supportedLocales: delegate.supportedLocales,
            locale: delegate.currentLocale,
            home: home,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // Only the validation path runs: nothing here reaches the payment call.
  testWidgets('wallet: an empty amount stops at validation', (
    WidgetTester tester,
  ) async {
    await pump(tester, const WalletTopupScreen());
    expect(find.byType(KTextField), findsWidgets);

    await tester.tap(find.widgetWithText(KButton, 'Top Up Wallet'));
    await tester.pump();

    expect(find.text(translate(AppStrings.required)), findsWidgets);
    expect(find.widgetWithText(KButton, 'Top Up Wallet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest profile: sign up and the four rows', (
    WidgetTester tester,
  ) async {
    await pump(tester, const Scaffold(body: ProfileGuestViewScreen()));
    expect(
      find.widgetWithText(KButton, translate(AppStrings.signUpNow)),
      findsOneWidget,
    );
    expect(find.byType(KListRow), findsNWidgets(4));
    expect(find.text(translate(AppStrings.howPointsWorks)), findsOneWidget);
  });

  testWidgets('guest notifications: message and sign up', (
    WidgetTester tester,
  ) async {
    await pump(tester, const GuestNotificationScreen());
    expect(
      find.text(translate(AppStrings.yourNotRegisteredYetJoinUs)),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(KButton, translate(AppStrings.signUpNow)),
      findsOneWidget,
    );
  });
}
