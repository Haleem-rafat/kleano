import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/biker_shell.dart';
import 'package:thewhsherbiker/modules/Home/screens/earnings_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/home_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/orders_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/accept_container.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/screens/profile_screen.dart';

import 'home_test_support.dart';

Future<void> pumpShell(WidgetTester t, {int initialIndex = 0}) async {
  await t.pumpWidget(app(BikerShell(initialIndex: initialIndex)));
  await settle(t);
}

Future<void> tapTab(WidgetTester t, String label) async {
  await t.tap(
    find.descendant(of: find.byType(GlassTabBar), matching: find.text(label)),
  );
  await settle(t);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setUpLanguages);
  setUp(setUpSpies);

  group('tabs', () {
    testWidgets('four tabs, opening on Today', (WidgetTester t) async {
      phone(t);
      onlineWithStats();
      await pumpShell(t);

      for (final String tab in <String>[
        'Today',
        'Orders',
        'Earnings',
        'Profile',
      ]) {
        expect(
          find.descendant(
            of: find.byType(GlassTabBar),
            matching: find.text(tab),
          ),
          findsOneWidget,
        );
      }
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(OrdersScreen), findsNothing);
    });

    testWidgets('each tab shows its screen', (WidgetTester t) async {
      phone(t);
      onlineWithStats();
      await pumpShell(t);

      await tapTab(t, 'Orders');
      expect(find.byType(OrdersScreen), findsOneWidget);

      await tapTab(t, 'Earnings');
      expect(find.byType(OrdersScreen), findsNothing);
      expect(find.byType(EarningsScreen), findsOneWidget);

      await tapTab(t, 'Profile');
      expect(find.byType(ProfileScreen), findsOneWidget);
      // A tab has nothing to go back to.
      expect(find.byType(GlassBackButton), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('the back button never pops the shell', (WidgetTester t) async {
      phone(t);
      onlineWithStats();
      await pumpShell(t);
      final NavigatorState navigator = t.state(find.byType(Navigator));
      await navigator.maybePop();
      await settle(t);
      expect(find.byType(BikerShell), findsOneWidget);
    });
  });

  group('calls', () {
    testWidgets('opening sends what Home always sent, once', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpShell(t);

      expect(notifications.sent.single, isA<GetBikerNotification>());
      expect(profile.sent[0], isA<BikerGetTotalWashes>());
      expect(profile.sent[1], isA<BikerGetTotalCommission>());
      expect(profile.sent, hasLength(2));
      expect(home.sent[0], isA<BikerGetNewOrders>());
      expect(home.sent[1], isA<BikerGetOrdersAccept>());
      expect(home.sent, hasLength(2));

      await tapTab(t, 'Earnings');
      await tapTab(t, 'Today');
      expect(notifications.sent, hasLength(1));
      expect(home.sent.whereType<BikerGetNewOrders>(), hasLength(1));
    });

    testWidgets('the socket starts only when online, on every tab', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'OFFLINE', totalWashes: 1);
      await pumpShell(t);
      await tapTab(t, 'Orders');
      await tapTab(t, 'Earnings');
      await tapTab(t, 'Profile');
      await tapTab(t, 'Today');
      expect(home.sent, isEmpty);
    });

    testWidgets('initial index 2 (from notifications) opens Completed', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpShell(t, initialIndex: 2);

      expect(t.takeException(), isNull);
      expect(find.byType(OrdersScreen), findsOneWidget);
      expect(home.sent.whereType<BikerGetNewOrders>(), hasLength(1));
      expect(home.sent.last, isA<BikerGetOrdersComplete>());
    });

    testWidgets('Orders reloads when opened and remembers its segment', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpShell(t);
      home.sent.clear();

      await tapTab(t, 'Orders');
      expect(home.sent.single, isA<BikerGetOrdersAccept>());

      await t.tap(find.text('Completed'));
      await settle(t);
      await tapTab(t, 'Today');
      home.sent.clear();

      await tapTab(t, 'Orders');
      expect(home.sent.single, isA<BikerGetOrdersComplete>());
    });

    testWidgets('Orders offline asks to go online and loads nothing', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'OFFLINE', totalWashes: 1);
      await pumpOrders(t);
      expect(home.sent, isEmpty);
      expect(find.text('Go Online Now'), findsOneWidget);
    });

    testWidgets('Active lists every order, first one included', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 2000) * 3;
      addTearDown(t.view.reset);
      onlineWithStats();
      home.activeList = <OrderModel>[order('a'), order('b')];
      await pumpOrders(t);
      expect(find.byType(AcceptContainer), findsNWidgets(2));
    });

    testWidgets('pulling Orders down reloads the list on screen', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpOrders(t, segment: OrdersSegment.completed);
      home.sent.clear();

      await t.fling(find.byType(CustomScrollView), const Offset(0, 400), 1000);
      await t.pump(const Duration(milliseconds: 300));
      await t.pump(const Duration(milliseconds: 300));
      expect(home.sent.single, isA<BikerGetOrdersComplete>());

      home.push(BikerGetOrdersCompleteEmpty());
      await settle(t);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('earnings', () {
    Future<void> pumpEarnings(WidgetTester t) async {
      await t.pumpWidget(app(const EarningsScreen()));
      await settle(t);
    }

    testWidgets('all time, today, weekends, then completed washes', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpEarnings(t);

      final double allTime = t.getTopLeft(find.text('980')).dy;
      final double today = t.getTopLeft(find.text('15')).dy;
      final double weekends = t.getTopLeft(find.text('200')).dy;
      final double washes = t.getTopLeft(find.text('120')).dy;
      expect(allTime, lessThan(today));
      expect(today, lessThan(weekends));
      expect(weekends, lessThan(washes));
      expect(find.text('Completed washes'), findsOneWidget);
      expect(find.text('20 orders'), findsOneWidget);
    });

    testWidgets('sends only the two existing events', (WidgetTester t) async {
      phone(t);
      onlineWithStats();
      await pumpEarnings(t);
      expect(profile.sent, hasLength(2));
      expect(profile.sent[0], isA<BikerGetTotalWashes>());
      expect(profile.sent[1], isA<BikerGetTotalCommission>());
      expect(home.sent, isEmpty);
    });

    testWidgets('loading, then a retry that reloads both on failure', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'ONLINE');
      await pumpEarnings(t);

      profile.push(BikerGetTotalCommissionLoading());
      await settle(t);
      expect(find.byType(KLoadingState), findsOneWidget);

      profile.push(BikerGetTotalCommissionFailed(error: 'x'));
      await settle(t);
      profile.sent.clear();
      await t.tap(find.byKey(const ValueKey<String>('k-error-retry')));
      expect(profile.sent, hasLength(2));
    });

    testWidgets('money not known yet is a dash, never a zero', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'ONLINE', totalWashes: 3);
      await pumpEarnings(t);
      profile.push(BikerProfileSuccess(profile: profile.profile));
      await settle(t);
      expect(find.text('0'), findsNothing);
      expect(find.text('—'), findsNWidgets(3));
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('every language and size', () {
    for (final String language in <String>['en', 'ar']) {
      testWidgets(
        '$language: every tab fits a small phone at the largest text',
        (WidgetTester t) async {
          phone(t, width: 320, height: 568);
          t.platformDispatcher.textScaleFactorTestValue = 1.35;
          addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
          await delegate.changeLocale(Locale(language));
          onlineWithStats();
          profile.profile
            ..phone = '+201012345678'
            ..createdAt = '11/9/2025';
          home.activeList = <OrderModel>[order('a')];
          await pumpShell(t);
          expect(t.takeException(), isNull);

          final List<String> labels = language == 'en'
              ? <String>['Orders', 'Earnings', 'Profile']
              : <String>['الطلبات', 'الأرباح', 'الملف الشخصي'];
          for (final String label in labels) {
            await tapTab(t, label);
            expect(t.takeException(), isNull);
          }
        },
      );
    }

    testWidgets('Arabic runs right to left', (WidgetTester t) async {
      phone(t);
      await delegate.changeLocale(const Locale('ar'));
      onlineWithStats();
      await pumpShell(t);
      expect(
        Directionality.of(t.element(find.byType(HomeScreen))),
        TextDirection.rtl,
      );
      // First tab on the right.
      expect(
        t.getCenter(find.text('اليوم').last).dx,
        greaterThan(t.getCenter(find.text('الملف الشخصي')).dx),
      );
    });

    testWidgets('one primary button on the offline Orders tab', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'OFFLINE', totalWashes: 1);
      await pumpOrders(t);
      final Iterable<KButton> buttons = t.widgetList<KButton>(
        find.byType(KButton),
      );
      expect(
        buttons.where((KButton b) => b.variant == KButtonVariant.primary),
        hasLength(1),
      );
    });
  });
}
