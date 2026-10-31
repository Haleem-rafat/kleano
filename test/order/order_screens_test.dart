import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/event_stepper.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/notification/screens/notification_screen.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_details_screen.dart';
import 'package:thewhsherbiker/modules/order/widgets/photo_source_sheet.dart';
import 'package:thewhsherbiker/modules/order/widgets/status_order_bottom_sheet.dart';
import 'package:thewhsherbiker/shared/components/alert_helper/order_pop_up.dart';

import '../home/home_test_support.dart';

Future<void> pumpPanel(WidgetTester t, String status, int step) async {
  home.orderDetails = order('o', status: status)..user = User(userName: 'Sam');
  home.orderStep = step;
  await t.pumpWidget(
    app(
      Scaffold(
        body: StatusOrderBottomSheet(order: home.orderDetails, index: 0),
      ),
    ),
  );
  await settle(t);
}

int primaries(WidgetTester t) => t
    .widgetList<KButton>(find.byType(KButton))
    .where((KButton b) => b.variant == KButtonVariant.primary)
    .length;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setUpLanguages);
  setUp(setUpSpies);

  group('change status panel', () {
    testWidgets('first Done says on the way; one primary', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1000) * 3;
      addTearDown(t.view.reset);
      await pumpPanel(t, 'ACCEPTED_BY_BIKER', -1);
      expect(primaries(t), 1);
      expect(
        t
            .widget<KButton>(find.widgetWithText(KButton, 'Complete Wash'))
            .onPressed,
        isNull,
      );

      await t.tap(find.widgetWithText(KButton, 'Done').first);
      expect(home.sent.single, isA<BikerOnTheWayOrder>());
    });

    testWidgets('steps can still be skipped, as before', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1000) * 3;
      addTearDown(t.view.reset);
      await pumpPanel(t, 'ACCEPTED_BY_BIKER', -1);
      await t.tap(find.widgetWithText(KButton, 'Done').at(1));
      expect(home.sent.single, isA<BikerArrivedOrder>());
    });

    testWidgets('start washing asks for a photo in a sheet', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1000) * 3;
      addTearDown(t.view.reset);
      await pumpPanel(t, 'BIKER_ARRIVED', 1);
      await t.tap(find.widgetWithText(KButton, 'Done'));
      await settle(t);
      expect(find.byType(PhotoSourceSheet), findsOneWidget);
      expect(home.sent, isEmpty);
    });

    testWidgets('washing: complete is the primary and asks for a photo', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1000) * 3;
      addTearDown(t.view.reset);
      await pumpPanel(t, 'ON_WASHING', 2);
      expect(primaries(t), 1);
      expect(find.widgetWithText(KButton, 'Done'), findsNothing);

      await t.tap(find.widgetWithText(KButton, 'Complete Wash'));
      await settle(t);
      expect(find.byType(PhotoSourceSheet), findsOneWidget);
    });

    testWidgets('a step moves on when the bloc says so', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1000) * 3;
      addTearDown(t.view.reset);
      await pumpPanel(t, 'ACCEPTED_BY_BIKER', -1);
      expect(find.widgetWithText(KButton, 'Done'), findsNWidgets(3));

      home.orderStep = 0;
      home.push(BikerOnTheWayOrderSuccess(orderId: 'o'));
      await settle(t);
      expect(find.widgetWithText(KButton, 'Done'), findsNWidgets(2));
    });

    test('other screens\' states do not touch the steps', () {
      expect(affectsOrderSteps(BikerGetOrdersAcceptLoading()), isFalse);
      expect(affectsOrderSteps(BikerArrivedOrderLoading()), isTrue);
    });
  });

  group('order details', () {
    testWidgets('a finished order has no actions', (WidgetTester t) async {
      await t.pumpWidget(
        app(OrderDetailsScreen(data: order('o'), complete: true)),
      );
      await settle(t);
      expect(t.takeException(), isNull);
      expect(find.byType(KButton), findsNothing);
    });

    testWidgets('a new order has Accept as its one primary', (
      WidgetTester t,
    ) async {
      await t.pumpWidget(
        app(OrderDetailsScreen(data: order('o'), complete: false, index: 0)),
      );
      await settle(t);
      expect(primaries(t), 1);
      await t.tap(find.widgetWithText(KButton, 'Accept'));
      final BikerAcceptOrder sent = home.sent.single as BikerAcceptOrder;
      expect(sent.details, isTrue);
      expect(sent.orderId, 'o');
    });
  });

  group('new request popup', () {
    testWidgets('lists requests; accept sends the same event', (
      WidgetTester t,
    ) async {
      phone(t);
      home.orderList = <OrderModel>[order('o')];
      auth.currentPosition = const LatLng(30, 31);
      await t.pumpWidget(app(const Scaffold(body: OrderPopUp())));
      await settle(t);
      expect(t.takeException(), isNull);

      await t.tap(find.widgetWithText(KButton, 'Accept'));
      final BikerAcceptOrder sent = home.sent.single as BikerAcceptOrder;
      expect(sent.details, isFalse);
    });

    testWidgets('no requests: an empty state', (WidgetTester t) async {
      phone(t);
      await t.pumpWidget(app(const Scaffold(body: OrderPopUp())));
      home.push(BikerGetOrdersEmpty());
      await settle(t);
      expect(t.takeException(), isNull);
      expect(find.text('New Requests'), findsOneWidget);
    });
  });

  group('notifications', () {
    testWidgets('opening loads them; failure offers a retry', (
      WidgetTester t,
    ) async {
      phone(t);
      await t.pumpWidget(app(const NotificationScreen()));
      await settle(t);
      expect(notifications.sent.single, isA<GetBikerNotification>());

      notifications.push(BikerNotificationFailed(error: 'x'));
      await settle(t);
      notifications.sent.clear();
      await t.tap(find.byKey(const ValueKey<String>('k-error-retry')));
      expect(notifications.sent.single, isA<GetBikerNotification>());
    });

    testWidgets('empty fits the screen', (WidgetTester t) async {
      phone(t, width: 320, height: 568);
      await t.pumpWidget(app(const NotificationScreen()));
      notifications.push(BikerNotificationEmpty());
      await settle(t);
      expect(t.takeException(), isNull);
    });
  });
}
