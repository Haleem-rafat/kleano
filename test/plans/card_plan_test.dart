import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/card_plan.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: <String>['en', 'ar'],
    );
    if (!sl.isRegistered<GetUserProfileBloc>()) {
      sl.registerSingleton<GetUserProfileBloc>(GetUserProfileBloc());
    }
  });

  setUp(() => AppShared.token = '');

  Plan plan({int points = 0, bool subscribed = false}) => Plan(
    sId: 'p1',
    type: 'Gold',
    color: '543063',
    price: 200,
    duration: 3,
    durationUnit: 'month',
    usageCount: 8,
    pointsToPay: points,
    isSubscribed: subscribed,
    description: <String>['Interior and exterior'],
    washingServices: <WashingServices>[
      WashingServices(sId: 's1', name: 'Foam wash'),
    ],
  );

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    TextDirection direction = TextDirection.ltr,
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      LocalizedApp(
        delegate,
        AdaptiveScreenUtil(
          builder: (_) => MaterialApp(
            theme: kleanoTheme(brightness: Brightness.light),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[delegate],
            supportedLocales: delegate.supportedLocales,
            locale: delegate.currentLocale,
            home: Directionality(
              textDirection: direction,
              child: Scaffold(body: SingleChildScrollView(child: child)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens on tap to show what the plan includes and its price', (
    WidgetTester tester,
  ) async {
    await pump(tester, CardOfPlan(plan: plan(), userHaveAPlan: false));
    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('Foam wash'), findsNothing);
    expect(find.byType(KButton), findsNothing);

    await tester.tap(find.text('Gold'));
    await tester.pumpAndSettle();

    expect(find.text('Interior and exterior'), findsOneWidget);
    expect(find.text('Foam wash'), findsOneWidget);
    expect(find.textContaining('200'), findsOneWidget);
    expect(find.byType(KButton), findsOneWidget);
  });

  testWidgets('a guest who taps subscribe gets the sign-up dialog', (
    WidgetTester tester,
  ) async {
    await pump(tester, CardOfPlan(plan: plan(), userHaveAPlan: false));
    await tester.tap(find.text('Gold'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(KButton));
    await tester.pumpAndSettle();

    expect(find.byType(KDialog), findsOneWidget);
  });

  testWidgets('on Home it cannot open and never offers to subscribe', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      CardOfPlan(
        plan: plan(),
        userHaveAPlan: true,
        comeformBooking: true,
        showExpandableContent: false,
      ),
    );
    await tester.tap(find.text('Gold'));
    await tester.pumpAndSettle();

    expect(find.text('Foam wash'), findsNothing);
    expect(find.byType(KButton), findsNothing);
  });

  testWidgets('shows points and Active as status chips', (
    WidgetTester tester,
  ) async {
    AppShared.token = 'token';
    await pump(
      tester,
      CardOfPlan(plan: plan(points: 50, subscribed: true), userHaveAPlan: true),
    );
    expect(find.byType(KStatusChip), findsNWidgets(2));
  });

  testWidgets('opens and shows the subscribe button on iOS', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pump(tester, CardOfPlan(plan: plan(), userHaveAPlan: false));
    await tester.tap(find.text('Gold'));
    await tester.pumpAndSettle();
    expect(find.byType(KButton), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('open card fits a 320pt screen in right-to-left', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      CardOfPlan(plan: plan(points: 50), userHaveAPlan: false),
      direction: TextDirection.rtl,
      width: 320,
    );
    await tester.tap(find.text('Gold'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
