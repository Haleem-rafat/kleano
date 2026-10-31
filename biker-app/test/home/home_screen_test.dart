import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_segmented.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/empty_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/home_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/accept_container.dart';
import 'package:thewhsherbiker/modules/Home/widget/completed_card.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';

import 'home_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setUpLanguages);
  setUp(setUpSpies);

  group('calls', () {
    testWidgets('opening Home sends the same events as before', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpHome(t);
      expect(notifications.sent.single, isA<GetBikerNotification>());
      expect(profile.sent, hasLength(2));
      expect(profile.sent[0], isA<BikerGetTotalWashes>());
      expect((profile.sent[0] as BikerGetTotalWashes).status, 'COMPLETED');
      expect(profile.sent[1], isA<BikerGetTotalCommission>());
      expect(home.sent, hasLength(2));
      expect(home.sent[0], isA<BikerGetNewOrders>());
      expect(home.sent[1], isA<BikerGetOrdersAccept>());
    });

    testWidgets('an offline biker opens no socket and loads no orders', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'OFFLINE', totalWashes: 1);
      await pumpHome(t);
      expect(home.sent, isEmpty);
    });

    testWidgets('each tab loads its list every time it is opened', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpOrders(t);
      home.sent.clear();

      await t.tap(find.text('Completed'));
      await settle(t);
      expect(home.sent.single, isA<BikerGetOrdersComplete>());

      home.sent.clear();
      await t.tap(find.text('Active'));
      await settle(t);
      expect(home.sent.single, isA<BikerGetOrdersAccept>());
    });

    testWidgets('going online also loads the active orders', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'OFFLINE', totalWashes: 1);
      await pumpHome(t);

      profile.profile.status = 'ONLINE';
      profile.push(BikerProfileSuccess(profile: profile.profile));
      await settle(t);
      expect(home.sent.single, isA<BikerGetOrdersAccept>());
    });
  });

  group('scrolling', () {
    testWidgets('pulling down refreshes what it always refreshed', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpHome(t);
      profile.sent.clear();
      home.sent.clear();

      await t.fling(find.byType(CustomScrollView), const Offset(0, 400), 1000);
      await t.pump(const Duration(milliseconds: 300));
      await t.pump(const Duration(milliseconds: 300));

      expect(profile.sent, hasLength(3));
      expect(profile.sent[0], isA<BikerProfile>());
      expect(profile.sent[1], isA<BikerGetTotalWashes>());
      expect(profile.sent[2], isA<BikerGetTotalCommission>());
      expect(home.sent.single, isA<BikerGetOrdersAccept>());
      await t.pump(const Duration(seconds: 2));
    });

    testWidgets('reaching the end asks for the next page of the open tab', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      home.activeList = <OrderModel>[
        for (int i = 0; i < 8; i++) order('active$i'),
      ];
      home.completeList = <OrderModel>[
        for (int i = 0; i < 8; i++) order('done$i', status: 'COMPLETED'),
      ];
      await pumpOrders(t);
      home.sent.clear();

      await t.fling(
        find.byType(CustomScrollView),
        const Offset(0, -6000),
        4000,
      );
      await settle(t);
      expect(home.sent.single, isA<BikerGetOrdersAcceptPagination>());

      home.push(BikerGetOrdersAcceptSuccess());
      await settle(t);
      home.sent.clear();

      await t.fling(find.byType(CustomScrollView), const Offset(0, 6000), 4000);
      await settle(t);
      await t.tap(find.text('Completed'));
      await settle(t);
      home.push(BikerGetOrdersCompleteSuccess());
      await settle(t);
      home.sent.clear();

      await t.fling(
        find.byType(CustomScrollView),
        const Offset(0, -6000),
        4000,
      );
      await settle(t);
      expect(home.sent.single, isA<BikerGetOrdersCompletePagination>());
    });

    testWidgets('an empty list never asks for a next page', (
      WidgetTester t,
    ) async {
      phone(t, width: 320, height: 568);
      onlineWithStats();
      await pumpOrders(t);
      home.sent.clear();

      await t.fling(
        find.byType(CustomScrollView),
        const Offset(0, -3000),
        3000,
      );
      await settle(t);
      expect(home.sent, isEmpty);
    });
  });

  group('online switch', () {
    testWidgets('turning it off asks for OFFLINE and waits for the backend', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpHome(t);
      profile.sent.clear();
      expect(find.widgetWithText(KStatusChip, 'Online'), findsOneWidget);

      await t.tap(find.byType(Switch));
      await settle(t);

      final BikerUpdateStatus sent = profile.sent.single as BikerUpdateStatus;
      expect(sent.status, 'OFFLINE');
      expect(t.widget<Switch>(find.byType(Switch)).value, isTrue);

      profile.profile.status = 'OFFLINE';
      profile.push(BikerProfileSuccess(profile: profile.profile));
      await settle(t);
      expect(t.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.widgetWithText(KStatusChip, 'Offline'), findsOneWidget);
    });

    testWidgets('offline: switch and button both ask for ONLINE', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'OFFLINE', totalWashes: 1);
      await pumpHome(t);
      profile.sent.clear();
      expect(
        find.byWidgetPredicate((Widget w) => w is KSegmented),
        findsNothing,
      );

      await t.tap(find.byType(Switch));
      await t.tap(find.text('Go Online Now'));
      await settle(t);

      expect(profile.sent, hasLength(2));
      for (final ProfileEvent e in profile.sent) {
        expect((e as BikerUpdateStatus).status, 'ONLINE');
      }
    });
  });

  group('layout', () {
    testWidgets('top bar: name and a glass bell', (WidgetTester t) async {
      phone(t);
      onlineWithStats();
      await pumpHome(t);
      expect(find.text('Haleem'), findsOneWidget);
      expect(find.byType(GlassBarButton), findsOneWidget);
    });

    testWidgets('the online switch, then the current order, then stats', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1400) * 3;
      addTearDown(t.view.reset);
      onlineWithStats();
      home.activeList = <OrderModel>[order('first'), order('second')];
      await pumpHome(t);

      final double status = t.getTopLeft(find.byType(Switch)).dy;
      final double focus = t
          .getTopLeft(find.byKey(const ValueKey<String?>('first')))
          .dy;
      final double stats = t.getTopLeft(find.text('Total Washes')).dy;
      expect(status, lessThan(focus));
      expect(focus, lessThan(stats));
      // The other orders and the lists live on the Orders tab.
      expect(find.byKey(const ValueKey<String?>('second')), findsNothing);
      expect(find.text('Active'), findsNothing);
    });

    testWidgets('each order keeps its real index in the bloc list', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 2000) * 3;
      addTearDown(t.view.reset);
      onlineWithStats();
      home.activeList = <OrderModel>[order('a'), order('b'), order('c')];
      await pumpOrders(t);

      final Map<String?, int> indexes = <String?, int>{
        for (final AcceptContainer c in t.widgetList<AcceptContainer>(
          find.byType(AcceptContainer),
        ))
          c.acceptOrder.sId: c.index,
      };
      expect(indexes, <String?, int>{'a': 0, 'b': 1, 'c': 2});
    });

    testWidgets('every order card has one primary action and big targets', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1200) * 3;
      addTearDown(t.view.reset);
      onlineWithStats();
      home.activeList = <OrderModel>[order('a')];
      await pumpHome(t);

      expect(find.text('Wash Progress'), findsOneWidget);
      final Finder call = find.bySemanticsLabel('Phone number');
      expect(t.getSize(call).shortestSide, greaterThanOrEqualTo(44));
      final Finder chat = find.bySemanticsLabel('WhatsApp').first;
      expect(t.getSize(chat).shortestSide, greaterThanOrEqualTo(44));
    });
  });

  group('list states', () {
    testWidgets('no orders: empty state; a new order then shows up', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpOrders(t);
      home.push(BikerGetOrdersAcceptEmpty());
      await settle(t);
      expect(find.byType(KEmptyState), findsOneWidget);
      expect(find.text('New Requests'), findsOneWidget);

      home.activeList = <OrderModel>[order('new')];
      home.push(BikerGetOrdersAcceptSuccess());
      await settle(t);
      expect(find.byType(AcceptContainer), findsOneWidget);
    });

    testWidgets('first load shows progress; failure offers a retry', (
      WidgetTester t,
    ) async {
      phone(t, height: 1400);
      onlineWithStats();
      await pumpOrders(t);

      home.push(BikerGetOrdersAcceptLoading());
      await settle(t);
      expect(find.byType(KSkeleton), findsOneWidget);

      home.push(BikerGetOrdersAcceptFailed(error: 'No connection'));
      await settle(t);
      expect(find.byType(KErrorState), findsOneWidget);

      home.sent.clear();
      await t.tap(find.byKey(const ValueKey<String>('k-error-retry')));
      expect(home.sent.single, isA<BikerGetOrdersAccept>());
    });

    testWidgets('orders on screen stay there while the list reloads', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      home.activeList = <OrderModel>[order('a')];
      await pumpOrders(t);

      home.push(BikerGetOrdersAcceptLoading());
      await settle(t);
      expect(find.byType(KSkeleton), findsNothing);
      expect(find.byType(AcceptContainer), findsOneWidget);
    });

    testWidgets('an order step taken elsewhere updates the card', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      home.activeList = <OrderModel>[order('a')];
      await pumpHome(t);
      expect(find.widgetWithText(KStatusChip, 'Accepted'), findsOneWidget);

      home.activeList.first.status = 'BIKER_ON_THE_WAY';
      home.push(BikerOnTheWayOrderSuccess(orderId: 'a'));
      await settle(t);
      expect(find.widgetWithText(KStatusChip, 'On the way'), findsOneWidget);
    });

    testWidgets('states for other screens do not rebuild the order cards', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      home.activeList = <OrderModel>[order('a')];
      await pumpHome(t);
      final Element before = t.element(find.byType(AcceptContainer));
      final Widget widgetBefore = before.widget;

      home.push(BikerOrderLoading());
      await settle(t);
      expect(identical(before.widget, widgetBefore), isTrue);
    });

    testWidgets('completed orders: count and cards; failure offers a retry', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1600) * 3;
      addTearDown(t.view.reset);
      onlineWithStats();
      await pumpOrders(t);
      await t.tap(find.text('Completed'));
      await settle(t);

      home.push(BikerGetOrdersCompleteFailed(error: 'Server error'));
      await settle(t);
      expect(find.byType(KErrorState), findsOneWidget);

      home.completeList = <OrderModel>[order('done', status: 'COMPLETED')];
      home.completeTotalLength = 1;
      home.push(BikerGetOrdersCompleteSuccess());
      await settle(t);
      expect(find.byType(CompletedCard), findsOneWidget);
      expect(find.text('1 Requests'), findsOneWidget);
    });

    testWidgets('stats: progress, then numbers, kept while they reload', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'OFFLINE');
      await pumpHome(t);
      profile.push(BikerGetTotalWashesLoading());
      await settle(t);
      expect(
        find.byType(KSkeleton),
        findsOneWidget,
      );

      onlineStatsOnly();
      profile.push(BikerProfileSuccess(profile: profile.profile));
      await settle(t);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('980'), findsOneWidget);

      profile.push(BikerGetTotalCommissionLoading());
      await settle(t);
      expect(find.text('120'), findsOneWidget);
    });

    testWidgets(
      'no numbers and nothing loading: zeros, never a stuck spinner',
      (WidgetTester t) async {
        phone(t);
        profile.profile = ProfileModel(status: 'OFFLINE');
        await pumpHome(t);
        profile.push(BikerGetTotalWashesLoading());
        await settle(t);

        profile.push(BikerProfileSuccess(profile: profile.profile));
        await settle(t);
        expect(find.byType(KSkeleton), findsNothing);
        expect(find.text('Total Washes'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      },
    );

    testWidgets('stats that never loaded offer a retry that reloads both', (
      WidgetTester t,
    ) async {
      phone(t);
      profile.profile = ProfileModel(status: 'OFFLINE');
      await pumpHome(t);
      profile.sent.clear();

      profile.push(BikerGetTotalCommissionFailed(error: 'Stats failed'));
      await settle(t);
      expect(find.byType(KErrorState), findsOneWidget);

      await t.tap(find.byKey(const ValueKey<String>('k-error-retry')));
      expect(profile.sent, hasLength(2));
      expect(profile.sent[0], isA<BikerGetTotalWashes>());
      expect(profile.sent[1], isA<BikerGetTotalCommission>());
    });
  });

  group('every language and size', () {
    testWidgets('Arabic: right to left, with Arabic status words', (
      WidgetTester t,
    ) async {
      phone(t);
      await delegate.changeLocale(const Locale('ar'));
      onlineWithStats();
      home.activeList = <OrderModel>[order('a')];
      await pumpHome(t);

      expect(t.takeException(), isNull);
      expect(find.widgetWithText(KStatusChip, 'متصل'), findsOneWidget);
      expect(
        Directionality.of(t.element(find.byType(HomeScreen))),
        TextDirection.rtl,
      );
      // Leading edge on the right: the avatar row starts past the middle.
      expect(
        t.getCenter(find.text('Haleem')).dx,
        greaterThan(t.getCenter(find.byType(GlassBarButton)).dx),
      );
    });

    testWidgets('Arabic offline prompt is translated too', (
      WidgetTester t,
    ) async {
      phone(t);
      await delegate.changeLocale(const Locale('ar'));
      profile.profile = ProfileModel(status: 'OFFLINE', totalWashes: 1);
      await pumpHome(t);
      expect(find.text('Go Online Now'), findsNothing);
      expect(find.widgetWithText(KStatusChip, 'غير متصل'), findsOneWidget);
    });

    testWidgets('changing language while Home is open updates its text', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      await pumpHome(t);
      expect(find.text('Total Washes'), findsOneWidget);

      await delegate.changeLocale(const Locale('ar'));
      await t.pumpWidget(app(const HomeScreen()));
      await settle(t);
      expect(find.text('Total Washes'), findsNothing);
      expect(find.widgetWithText(KStatusChip, 'متصل'), findsOneWidget);
    });

    testWidgets('iOS controls lay out with an order on screen', (
      WidgetTester t,
    ) async {
      phone(t);
      onlineWithStats();
      home.activeList = <OrderModel>[order('a'), order('b')];
      await pumpHome(t);
      expect(t.takeException(), isNull);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Wash Progress'), findsWidgets);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    for (final String language in <String>['en', 'ar']) {
      testWidgets('$language fits a small phone at the largest text', (
        WidgetTester t,
      ) async {
        phone(t, width: 320, height: 568);
        t.platformDispatcher.textScaleFactorTestValue = 1.35;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        await delegate.changeLocale(Locale(language));
        onlineWithStats();
        home.activeList = <OrderModel>[
          order('a')
            ..isAssigned = true
            ..user = User(userName: 'A customer with a very long name indeed'),
        ];
        await pumpHome(t);
        expect(t.takeException(), isNull);
      });
    }
  });

  group('empty screen', () {
    testWidgets('fits where the notification screen hosts it', (
      WidgetTester t,
    ) async {
      phone(t, width: 320, height: 568);
      await t.pumpWidget(
        app(
          Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 120,
                      child: EmptyScreen(
                        notification: true,
                        text: 'letYouKnow',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await settle(t);
      expect(t.takeException(), isNull);
      expect(find.byType(KEmptyState), findsOneWidget);
    });
  });
}

