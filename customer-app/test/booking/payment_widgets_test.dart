import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/modules/booking/data/models/payment_type_model.dart';
import 'package:thewasher/modules/booking/widgets/action_bottom_sheet.dart';
import 'package:thewasher/modules/booking/widgets/card_form.dart';
import 'package:thewasher/modules/booking/widgets/card_payment_type.dart';

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

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    TextDirection direction = TextDirection.ltr,
  }) async {
    await tester.pumpWidget(
      LocalizedApp(
        delegate,
        AdaptiveScreenUtil(
          builder: (_) => MaterialApp(
            theme: kleanoTheme(brightness: Brightness.light),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[delegate],
            supportedLocales: delegate.supportedLocales,
            home: Directionality(
              textDirection: direction,
              child: Scaffold(body: child),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('CardPaymentMethod', () {
    final PaymentMethodModel wallet = PaymentMethodModel(
      image: AssetsManager.wallet,
      title: 'Wallet',
      value: 2,
    );

    testWidgets('shows the wallet balance with the riyal symbol', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        KCard(
          padding: EdgeInsets.zero,
          child: CardPaymentMethod(
            type: wallet,
            groupValue: 1,
            walletBalance: 12.5,
            isWallet: true,
          ),
        ),
      );
      expect(find.text('Balance: 12.50'), findsOneWidget);
      expect(find.byType(SvgPicture), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('marks only the selected method and reports taps', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await pump(
        tester,
        KCard(
          padding: EdgeInsets.zero,
          child: CardPaymentMethod(
            type: wallet,
            groupValue: 2,
            walletBalance: 0,
            isWallet: false,
            onTap: () => taps++,
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      await tester.tap(find.text('Wallet'));
      expect(taps, 1);
    });
  });

  group('CardForm', () {
    late GlobalKey<FormState> key;
    late TextEditingController name, number, expiry, cvv;

    setUp(() {
      key = GlobalKey<FormState>();
      name = TextEditingController();
      number = TextEditingController();
      expiry = TextEditingController();
      cvv = TextEditingController();
    });

    Widget form() => SingleChildScrollView(
      child: CardForm(
        formKey: key,
        nameController: name,
        numberController: number,
        expiryController: expiry,
        cvvController: cvv,
      ),
    );

    testWidgets('keeps its validators and formatters', (
      WidgetTester tester,
    ) async {
      await pump(tester, form());
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Please enter your card number'), findsOneWidget);

      final Finder fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'ali 7');
      await tester.enterText(fields.at(1), '4111111111111111999');
      await tester.enterText(fields.at(2), '1299');
      await tester.enterText(fields.at(3), '123');
      await tester.pump();
      expect(name.text, 'ALI ');
      expect(number.text.replaceAll(' ', ''), '4111111111111111');
      expect(expiry.text, '12/99');
      expect(key.currentState!.validate(), isTrue);
    });

    testWidgets('in Arabic the digits read left to right, label on the right', (
      WidgetTester tester,
    ) async {
      await pump(tester, form(), direction: TextDirection.rtl);

      final Finder numberField = find.byType(EditableText).at(1);
      expect(Directionality.of(tester.element(numberField)), TextDirection.ltr);

      final Finder label = find.text('Card Number').first;
      final RenderParagraph paragraph = tester.renderObject(label);
      expect(paragraph.textAlign, TextAlign.right);
      expect(tester.takeException(), isNull);
    });
  });

  group('ActionsBottom', () {
    testWidgets('OK reports the choice', (WidgetTester tester) async {
      int chosen = 0;
      await pump(tester, ActionsBottom(onDateSelected: () => chosen++));
      await tester.tap(find.byType(TextButton).last);
      expect(chosen, 1);
    });

    testWidgets('sits at the end of the line in both directions', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        ActionsBottom(onDateSelected: () {}),
        direction: TextDirection.rtl,
      );
      final double screenWidth = tester.getSize(find.byType(Scaffold)).width;
      final Rect ok = tester.getRect(find.byType(TextButton).last);
      expect(ok.left, lessThan(screenWidth / 2));
    });
  });
}
