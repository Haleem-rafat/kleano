import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/card_plan.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class _SpyPlansBloc extends PlansAndSubscriptionBloc {
  final List<PlansAndSubscriptionEvent> events = <PlansAndSubscriptionEvent>[];

  @override
  void add(PlansAndSubscriptionEvent event) => events.add(event);

  void push(PlansAndSubscriptionState state) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;
  late _SpyPlansBloc bloc;

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

  setUp(() {
    AppShared.token = '';
    bloc = _SpyPlansBloc();
    if (sl.isRegistered<PlansAndSubscriptionBloc>()) {
      sl.unregister<PlansAndSubscriptionBloc>();
    }
    sl.registerSingleton<PlansAndSubscriptionBloc>(bloc);
  });

  List<Plan> plans(int count) => <Plan>[
    for (int i = 0; i < count; i++)
      Plan(
        sId: 'p$i',
        type: 'Plan $i',
        color: '543063',
        price: 100,
        duration: 1,
        durationUnit: 'month',
        usageCount: 4,
        pointsToPay: 0,
        isSubscribed: false,
      ),
  ];

  Future<void> pump(WidgetTester tester, {String? highlightPlanId}) async {
    await tester.pumpWidget(
      LocalizedApp(
        delegate,
        AdaptiveScreenUtil(
          builder: (_) => MaterialApp(
            theme: kleanoTheme(brightness: Brightness.light),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[delegate],
            supportedLocales: delegate.supportedLocales,
            locale: delegate.currentLocale,
            home: BlocProvider<PlansAndSubscriptionBloc>.value(
              value: bloc,
              child: PlansAndSubscriptionScreen(
                highlightPlanId: highlightPlanId,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a guest asks for the guest plans and sees them', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(bloc.events.single, isA<GetAllPlansForGuest>());

    bloc.push(GetPlansSuccess(plans: plans(2)));
    await tester.pumpAndSettle();

    expect(find.byType(CardOfPlan), findsNWidgets(2));
    expect(find.text('Plan 1'), findsOneWidget);
  });

  testWidgets('loading and connection error use the design system states', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    bloc.push(GetPlansLoading());
    await tester.pump();
    expect(find.byType(KSkeleton), findsOneWidget);

    bloc.push(PlansAndSubscriptionConnectionError());
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('k-error-retry')));
    expect(bloc.events, hasLength(2));
  });

  testWidgets('a banner link scrolls its plan into view, even the last one', (
    WidgetTester tester,
  ) async {
    await pump(tester, highlightPlanId: 'p19');
    bloc.push(GetPlansSuccess(plans: plans(20)));
    await tester.pumpAndSettle();

    final CardOfPlan card = tester.widget<CardOfPlan>(
      find.byWidgetPredicate(
        (Widget w) => w is CardOfPlan && w.plan.sId == 'p19',
      ),
    );
    expect(card.isHighlighted, isTrue);
    // Every card stays built, so the first card has scrolled off the top and
    // the highlighted one is on screen.
    final double screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(tester.getBottomLeft(find.text('Plan 0')).dy, lessThan(0));
    expect(
      tester.getBottomLeft(find.text('Plan 19')).dy,
      lessThan(screenHeight),
    );
  });
}
