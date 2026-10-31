import 'package:flutter/material.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/screens/wash_details.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class _SpyOrderBloc extends BookingOrderBloc {
  final List<BookingOrderEvent> events = <BookingOrderEvent>[];

  @override
  void add(BookingOrderEvent event) => events.add(event);

  void push(BookingOrderState state) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state);
  }
}

class _QuietSocketBloc extends SocketBloc {
  @override
  void add(SocketEvent event) {}

  void push(SocketState state) => emit(state);
}

class _QuietMyBookingBloc extends MyBookingBloc {
  @override
  void add(MyBookingEvent event) {}
}

late _QuietSocketBloc socketBloc;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;
  late _SpyOrderBloc bloc;

  setUpAll(() async {
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: <String>['en', 'ar'],
    );
  });

  setUp(() {
    socketBloc = _QuietSocketBloc();
    bloc = _SpyOrderBloc();
    if (sl.isRegistered<BookingOrderBloc>()) {
      sl.unregister<BookingOrderBloc>();
    }
    sl.registerSingleton<BookingOrderBloc>(bloc);
    if (!sl.isRegistered<MyBookingBloc>()) {
      sl.registerSingleton<MyBookingBloc>(_QuietMyBookingBloc());
    }
  });

  // No location: the Google Map is a platform view tests can't render.
  OrderModel order({String status = 'ACTIVE', double? rating}) {
    final OrderModel order = OrderModel();
    order.sId = 'abcdef123456';
    order.status = status;
    order.paymentType = 'WALLET';
    order.createdAt = '2026-10-30T10:00:00.000Z';
    order.totalPrice = 100;
    order.totalPay = 80;
    order.ratingOfBiker = rating;
    order.addOns = <AddOnsModel>[];
    order.washingServices = <ServiceModel>[];
    return order;
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      LocalizedApp(
        delegate,
        AdaptiveScreenUtil(
          builder: (_) => MaterialApp(
            theme: kleanoTheme(brightness: Brightness.light),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[delegate],
            supportedLocales: delegate.supportedLocales,
            locale: delegate.currentLocale,
            home: BlocProvider<SocketBloc>(
              create: (_) => socketBloc,
              child: BlocProvider<BookingOrderBloc>.value(
                value: bloc,
                child: const WashDetailsScreen(orderId: 'abcdef123456'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a status change from the biker reloads the order', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(bloc.events.whereType<GetOrderById>(), hasLength(1));
    socketBloc.push(ReceivedOrderCompletedSuccess(orderId: 'abcdef123456'));
    await tester.pump();
    expect(bloc.events.whereType<GetOrderById>(), hasLength(2));
  });

  testWidgets('asks for the order, then shows id, chips and the prices', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(bloc.events.single, isA<GetOrderById>());

    bloc.push(OrderByIdLoading());
    await tester.pump();
    expect(find.byType(KLoadingState), findsOneWidget);

    bloc.push(OrderByIdSuccess(orderModel: order()));
    await tester.pumpAndSettle();

    expect(find.text('# 123456'), findsOneWidget);
    expect(find.byType(KStatusChip), findsNWidgets(2));
    expect(find.textContaining('100'), findsOneWidget);
    expect(find.textContaining('-20'), findsOneWidget);
    expect(find.textContaining('80'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('only a cancellable order offers cancel', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    bloc.push(OrderByIdSuccess(orderModel: order()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    bloc.push(OrderByIdSuccess(orderModel: order(status: 'BIKER_ON_THE_WAY')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('a finished unrated wash has one primary: rate it', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    bloc.push(
      OrderByIdSuccess(orderModel: order(status: 'COMPLETED', rating: 0)),
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(KButton, translate(AppStrings.rateWashNow)),
      findsOneWidget,
    );
    expect(find.byType(KButton), findsOneWidget);
  });

  testWidgets('services and add-ons switch with the segmented control', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    bloc.push(OrderByIdSuccess(orderModel: order()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(translate(AppStrings.noServicesRequested)),
      200,
    );
    await tester.tap(find.text(translate(AppStrings.addOns)));
    await tester.pumpAndSettle();
    expect(find.text(translate(AppStrings.noAddonsRequested)), findsOneWidget);
  });

  testWidgets('a failed load can be retried', (WidgetTester tester) async {
    await pump(tester);
    bloc.push(OrderByIdFailed(error: 'Nope'));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey<String>('k-error-retry')));
    expect(bloc.events, hasLength(2));
    expect(bloc.events.last, isA<GetOrderById>());
  });
}
