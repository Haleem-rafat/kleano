import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_auth_scaffold.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_text_field.dart';
import 'package:thewhsherbiker/core/design/kleano_theme.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/phone_auth/phone_number_verification_cubit.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/modules/Auth/screens/otp_screen.dart';
import 'package:thewhsherbiker/modules/Auth/screens/phone_number.dart';
import 'package:thewhsherbiker/modules/Auth/screens/update_password.dart';
import 'package:thewhsherbiker/modules/on_boarding/on_boarding_screen.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// Records the events the screens send instead of calling the backend.
class SpyAuthBloc extends AuthBloc {
  final List<AuthEvent> sent = <AuthEvent>[];

  @override
  void add(AuthEvent event) => sent.add(event);

  void push(AuthState state) => emit(state);
}

late LocalizationDelegate delegate;
late SpyAuthBloc bloc;

Widget app(Widget home) => LocalizedApp(
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

  setUp(() async {
    await sl.reset();
    bloc = SpyAuthBloc();
    sl.registerSingleton<AuthBloc>(bloc);
  });

  group('login', () {
    testWidgets('shows Welcome back, username, password and Log in', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LogInScreen()));
      await t.pumpAndSettle();
      expect(find.byType(KAuthScaffold), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(KTextField), findsNWidgets(2));
      expect(find.widgetWithText(KButton, 'Login'), findsOneWidget);
    });

    testWidgets('Log in stays visible with the keyboard open', (WidgetTester t) async {
      phone(t, keyboard: 300);
      await t.pumpWidget(app(const LogInScreen()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(t.getRect(find.widgetWithText(KButton, 'Login')).bottom,
          lessThanOrEqualTo(667 - 300));
    });

    testWidgets('empty fields show errors and send no login', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LogInScreen()));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(KButton, 'Login'));
      await t.pumpAndSettle();
      expect(bloc.sent.whereType<BikerLogin>(), isEmpty);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('valid fields send a BikerLogin with the typed values', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LogInScreen()));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField).at(0), 'ahmedbiker');
      await t.enterText(find.byType(TextFormField).at(1), 'secret123');
      await t.tap(find.widgetWithText(KButton, 'Login'));
      await t.pumpAndSettle();
      final BikerLogin e = bloc.sent.whereType<BikerLogin>().single;
      expect(e.userName, 'ahmedbiker');
      expect(e.passWord, 'secret123');
    });

    testWidgets('loading state shows progress in the button', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const LogInScreen()));
      bloc.push(BikerLoginLoading());
      await t.pump();
      expect(t.widget<KButton>(find.byType(KButton).first).loading, isTrue);
    });
  });

  testWidgets('forgot password: phone screen uses the auth layout', (WidgetTester t) async {
    phone(t);
    await t.pumpWidget(app(BlocProvider<PhoneNumberVerificationCubit>(
      create: (_) => PhoneNumberVerificationCubit(),
      child: const PhoneNumberScreen(),
    )));
    await t.pumpAndSettle();
    expect(find.byType(KAuthScaffold), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('OTP screen offers SMS code autofill', (WidgetTester t) async {
    phone(t);
    await t.pumpWidget(app(BlocProvider<PhoneNumberVerificationCubit>(
      create: (_) => PhoneNumberVerificationCubit(),
      child: const OtpScreen(phone: '+966500000000', verificationId: 'v'),
    )));
    await t.pump();
    expect(find.byType(KAuthScaffold), findsOneWidget);
    // pin_code_fields captures input with a hidden EditableText.
    final Iterable<EditableText> fields = t.widgetList<EditableText>(find.byType(EditableText));
    expect(
        fields.any((EditableText f) => f.autofillHints?.contains(AutofillHints.oneTimeCode) ?? false),
        isTrue);
  });

  testWidgets('new password screen uses the auth layout with two password fields',
      (WidgetTester t) async {
    phone(t);
    await t.pumpWidget(app(const UpdatePassword(profile: false)));
    await t.pumpAndSettle();
    expect(find.byType(KAuthScaffold), findsOneWidget);
    expect(find.byType(KTextField), findsNWidgets(2));
  });

  testWidgets('onboarding: translated pages, Next then Get started, Skip', (WidgetTester t) async {
    phone(t);
    await t.pumpWidget(app(const OnboardScreen()));
    await t.pumpAndSettle();
    expect(find.text('Accept requests'), findsOneWidget);
    expect(find.widgetWithText(KButton, 'Next'), findsOneWidget);
    expect(find.widgetWithText(KButton, 'Skip'), findsOneWidget);
    await t.tap(find.widgetWithText(KButton, 'Next'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(KButton, 'Next'));
    await t.pumpAndSettle();
    expect(find.text('Earn on every wash'), findsOneWidget);
    expect(find.widgetWithText(KButton, 'Get Started'), findsOneWidget);
    expect(find.widgetWithText(KButton, 'Skip'), findsNothing);
    expect(t.takeException(), isNull);
  });
}
