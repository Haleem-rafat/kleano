import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/widgets/button_tracking.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_card.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;

  setUpAll(() async {
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: <String>['en', 'ar'],
    );
  });

  OrderModel order({String status = 'ACTIVE', String? startTime}) {
    final OrderModel order = OrderModel();
    order.sId = 'order-1';
    order.status = status;
    order.paymentType = 'WALLET';
    order.createdAt = '2026-10-30T10:00:00.000Z';
    order.startTime = startTime;
    order.vehicle = Vehicle(
      brand: 'Toyota',
      model: 'Corolla',
      plateNumber: 'ABC 123',
      color: 'Red',
    )..imageLink = '';
    return order;
  }

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
              child: Scaffold(body: child),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  test('every booking status maps to the design system chip colour', () {
    const Map<String, KStatus> expected = <String, KStatus>{
      'COMPLETED': KStatus.success,
      'ACTIVE': KStatus.brand,
      'ACCEPTED_BY_BIKER': KStatus.brand,
      'PENDING_USER_PAYMENT': KStatus.warning,
      'PENDING_USER_REVIEW': KStatus.warning,
      'WAITING_FOR_BIKER_BY_ADMIN': KStatus.warning,
      'ORDER_WAITING_FOR_ADMIN': KStatus.warning,
      'BIKER_ON_THE_WAY': KStatus.warning,
      'BIKER_ARRIVED': KStatus.warning,
      'ON_WASHING': KStatus.warning,
      'CANCELLED_BY_USER': KStatus.error,
      'CANCELLED_BY_ADMIN': KStatus.error,
      'CANCELLED_BY_BIKER': KStatus.error,
      'SCHEDULED': KStatus.neutral,
      'SOMETHING_NEW': KStatus.neutral,
    };
    expected.forEach((String status, KStatus kind) {
      expect(MyBookingCard.statusKind(status), kind, reason: status);
    });
  });

  testWidgets('statusText stays public and translated for Home', (
    WidgetTester tester,
  ) async {
    await pump(tester, const SizedBox());
    expect(
      MyBookingCard.statusText('BIKER_ON_THE_WAY'),
      translate(AppStrings.onTheWay),
    );
    expect(MyBookingCard.statusText('SOMETHING_NEW'), 'SOMETHING_NEW');
  });

  testWidgets('shows the car, status and payment chips and details action', (
    WidgetTester tester,
  ) async {
    await pump(tester, MyBookingCard(order: order()));
    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.byType(KStatusChip), findsNWidgets(2));
    expect(find.text(translate(AppStrings.viewDetails)), findsOneWidget);
    expect(find.byType(ButtonTrackingOrder), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tracking is offered only for an active order on the way', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      MyBookingCard(order: order(status: 'BIKER_ON_THE_WAY'), isActive: true),
    );
    expect(find.byType(ButtonTrackingOrder), findsOneWidget);

    await pump(tester, MyBookingCard(order: order(status: 'BIKER_ON_THE_WAY')));
    expect(find.byType(ButtonTrackingOrder), findsNothing);
  });

  testWidgets('fits a 320pt screen in right-to-left with both dates', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      SingleChildScrollView(
        child: MyBookingCard(
          order: order(
            status: 'BIKER_ON_THE_WAY',
            startTime: '2026-10-30T12:00:00.000Z',
          ),
          isActive: true,
        ),
      ),
      direction: TextDirection.rtl,
      width: 320,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long list builds only the cards near the screen', (
    WidgetTester tester,
  ) async {
    final RefreshController controller = RefreshController();
    addTearDown(controller.dispose);
    await pump(
      tester,
      MyBookingList(
        refreshController: controller,
        onRefresh: () {},
        onLoading: () {},
        orderList: List<OrderModel>.generate(200, (_) => order()),
        emptyText: AppStrings.thereIsNoActiveBookingYet,
      ),
    );
    final int built = find
        .byType(MyBookingCard, skipOffstage: false)
        .evaluate()
        .length;
    expect(built, greaterThan(0));
    expect(built, lessThan(30));
  });

  testWidgets('an empty list shows the empty message', (
    WidgetTester tester,
  ) async {
    final RefreshController controller = RefreshController();
    addTearDown(controller.dispose);
    await pump(
      tester,
      MyBookingList(
        refreshController: controller,
        onRefresh: () {},
        onLoading: () {},
        orderList: const <OrderModel>[],
        emptyText: AppStrings.thereIsNoActiveBookingYet,
      ),
    );
    expect(
      find.text(translate(AppStrings.thereIsNoActiveBookingYet)),
      findsOneWidget,
    );
  });
}
