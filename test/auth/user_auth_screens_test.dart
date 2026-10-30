import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_auth_scaffold.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/screens/log_in_screen.dart';
import 'package:thewasher/modules/Auth/screens/otp_screen.dart';
import 'package:thewasher/modules/Auth/screens/sign_up_screen.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/on_boarding/on_boarding_screen.dart';

/// Records calls instead of hitting the backend.
class SpyAuthCubit extends AuthCubit {
  final List<String> calls = <String>[];

  @override
  Future<void> sendOTP({required String phone}) async => calls.add('sendOTP:$phone');
}

late LocalizationDelegate delegate;
late SpyAuthCubit cubit;

Widget app(Widget home) => LocalizedApp(
      delegate,
      AdaptiveScreenUtil(
        builder: (_) => BlocProvider<AuthCubit>.value(
          value: cubit,
          child: MaterialApp(
            theme: kleanoTheme(brightness: Brightness.light),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[delegate],
            supportedLocales: delegate.supportedLocales,
            locale: delegate.currentLocale,
            home: home,
          ),
        ),
      ),
    );

void phone(WidgetTester t, {double keyboard = 0}) {
  t.view.devicePixelRatio = 3;
  t.view.physicalSize = const Size(375, 667) * 3;
  t.view.viewInsets = FakeViewPadding(bottom: keyboard * 3);
  addTearDown(t.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
        fallbackLocale: 'en', supportedLocales: <String>['en', 'ar']);
  });

  setUp(() => cubit = SpyAuthCubit());

  testWidgets('choose register: Sign up, Log in and Continue as a guest', (WidgetTester t) async {
    phone(t);
    await t.pumpWidget(app(ChooseRegisterView()));
    await t.pumpAndSettle();
    expect(find.byType(KButton), findsNWidgets(3));
    expect(t.takeException(), isNull);
  });

  group('login', () {
    testWidgets('uses the auth layout with a phone field', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LogInScreen()));
      await t.pumpAndSettle();
      expect(find.byType(KAuthScaffold), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(KTextField), findsOneWidget);
    });

    testWidgets('Continue stays visible with the keyboard open', (WidgetTester t) async {
      phone(t, keyboard: 300);
      await t.pumpWidget(app(const LogInScreen()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final Rect primary = t.getRect(find.byType(KButton).first);
      expect(primary.bottom, lessThanOrEqualTo(667 - 300));
    });

    testWidgets('a local Egyptian number is sent as +20 without the trunk 0',
        (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LogInScreen()));
      await t.pumpAndSettle();
      expect(find.text('+20'), findsOneWidget);
      await t.enterText(find.byType(TextFormField), '01202939672');
      await t.tap(find.byType(KButton).first);
      await t.pumpAndSettle();
      expect(cubit.calls.single, 'sendOTP:+201202939672');
    });
  });

  testWidgets('sign up: name, email, phone fields and a terms reminder', (WidgetTester t) async {
    phone(t);
    await t.pumpWidget(app(const SignUpScreen()));
    await t.pumpAndSettle();
    expect(find.byType(KAuthScaffold), findsOneWidget);
    expect(find.byType(KTextField), findsNWidgets(3));
    await t.enterText(find.byType(TextFormField).at(1), 'not-an-email');
    await t.tap(find.widgetWithText(KButton, translate('signUp')));
    await t.pumpAndSettle();
    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(cubit.calls, isEmpty);
  });

  testWidgets('OTP offers SMS code autofill and locks resend during the timer',
      (WidgetTester t) async {
    phone(t);
    await t.pumpWidget(app(const OtpScreen(phone: '+966512345678', fcmToken: 't', isSignup: false)));
    await t.pump();
    expect(find.byType(KAuthScaffold), findsOneWidget);
    final Iterable<EditableText> fields = t.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.any((EditableText f) => f.autofillHints?.contains(AutofillHints.oneTimeCode) ?? false),
        isTrue);
    final KButton resend = t.widgetList<KButton>(find.byType(KButton))
        .firstWhere((KButton b) => b.variant == KButtonVariant.text);
    expect(resend.onPressed, isNull);
  });

  testWidgets('onboarding shows Next and Skip without overflow', (WidgetTester t) async {
    phone(t);
    await t.pumpWidget(app(const OnboardScreen()));
    await t.pumpAndSettle();
    expect(find.widgetWithText(KButton, translate('next')), findsOneWidget);
    expect(find.widgetWithText(KButton, translate('skip')), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
