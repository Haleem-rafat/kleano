import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/apply_promo_code_model.dart';
import 'package:thewasher/modules/booking/screens/order_detalis_screen.dart';
import 'package:thewasher/modules/booking/widgets/card_payment_type.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/vehicles_model.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/widgets/button_use_promo.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

/// Every bloc here swallows its events, so nothing can reach the backend.
class _SpyBooking extends BookingOrderBloc {
  final List<BookingOrderEvent> events = <BookingOrderEvent>[];

  @override
  void add(BookingOrderEvent event) => events.add(event);
}

class _SpyPromo extends PromoBloc {
  final List<PromoEvent> events = <PromoEvent>[];

  @override
  void add(PromoEvent event) => events.add(event);

  void push(PromoState state) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state);
  }
}

/// Stands in for the native Google Map.
class _FakeMaps extends GoogleMapsFlutterPlatform {
  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) => const SizedBox.expand();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;
  late _SpyBooking booking;
  late _SpyPromo promo;
  late OffersBloc offers;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: <String>['en', 'ar'],
    );
    await initializeDateFormatting('en');
    GoogleMapsFlutterPlatform.instance = _FakeMaps();
  });

  setUp(() async {
    await sl.reset();
    booking = _SpyBooking();
    promo = _SpyPromo();
    offers = OffersBloc()..total = 150;
    sl.registerSingleton<BookingOrderBloc>(booking);
    sl.registerSingleton<PromoBloc>(promo);
    sl.registerSingleton<OffersBloc>(offers);
    sl.registerSingleton<LocationBloc>(LocationBloc());
    sl.registerSingleton<PlansAndSubscriptionBloc>(PlansAndSubscriptionBloc());
    sl.registerSingleton<VehiclesBloc>(
      VehiclesBloc()
        ..selectedVehicle = VehiclesModel(
          sId: 'car-1',
          brand: 'Toyota',
          model: 'Camry',
          color: 'White',
          plateNumber: 'ABC 123',
        ),
    );
    sl.registerSingleton<GetUserProfileBloc>(
      GetUserProfileBloc()
        ..profile = (Profile()
          ..isSubscribed = false
          ..points = 100),
    );
    walletBalance = 20;
    copiedPromoCode = null;
    GeneralSingleton().totalPay = null;
    GeneralSingleton().orderId = null;
    GeneralSingleton().orderTime = DateTime(2026, 11, 2, 9, 30);
    GeneralSingleton().nearByDescription = 'Gate 4';
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await delegate.changeLocale(locale);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      LocalizedApp(
        delegate,
        AdaptiveScreenUtil(
          builder: (_) => MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<PromoBloc>.value(value: promo),
              BlocProvider<BookingOrderBloc>.value(value: booking),
            ],
            child: MaterialApp(
              theme: kleanoTheme(brightness: Brightness.light),
              localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: delegate.supportedLocales,
              locale: locale,
              builder: (BuildContext context, Widget? child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: Directionality(
                  textDirection: locale.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: child!,
                ),
              ),
              home: const OrderDetalisScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
  }

  for (final Locale locale in const <Locale>[Locale('en'), Locale('ar')]) {
    for (final (Size size, double scale) in const <(Size, double)>[
      (Size(390, 844), 1),
      (Size(320, 568), 1.35),
    ]) {
      testWidgets('lays out without overflow: ${locale.languageCode}, '
          '${size.width.toInt()}pt, text x$scale', (WidgetTester tester) async {
        await pump(tester, locale: locale, size: size, textScale: scale);
        expect(tester.takeException(), isNull);
        expect(find.text('Toyota Camry'), findsOneWidget);
        expect(find.text('Gate 4'), findsOneWidget);

        // Fill every conditional part of the screen.
        promo.push(
          GetPromoCodeDetailSuccess(
            promoCodeDetail: NewPromoCodeModel(
              discountAmount: 50,
              totalPayAfterDiscount: 100,
            ),
          ),
        );
        await tester.pump();
        final Finder pointsField = find.byType(EditableText).last;
        await scrollTo(tester, pointsField);
        await tester.enterText(pointsField, '5000');
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('no confirm button until a payment method is chosen', (
    WidgetTester tester,
  ) async {
    walletBalance = 500;
    await pump(tester);
    expect(find.text('Confirm Order'), findsNothing);

    await scrollTo(tester, find.textContaining('Balance'));
    await tester.tap(find.textContaining('Balance'));
    await tester.pump();

    expect(find.text('Confirm Order'), findsOneWidget);
    expect(booking.paymentType, 2);
    // Choosing a method alone sends nothing.
    expect(booking.events, isEmpty);
  });

  testWidgets('a wallet that cannot cover the order is not selected', (
    WidgetTester tester,
  ) async {
    walletBalance = 20;
    await pump(tester);

    await scrollTo(tester, find.textContaining('Balance'));
    await tester.tap(find.textContaining('Balance'));
    await tester.pump();

    expect(booking.paymentType, isNot(2));
    expect(find.text('Confirm Order'), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('choosing card opens a sheet that validates and formats', (
    WidgetTester tester,
  ) async {
    await pump(tester);

    await scrollTo(tester, find.text('Credit cards'));
    await tester.tap(find.text('Credit cards'));
    await tester.pumpAndSettle();
    expect(find.text('Pay Now'), findsOneWidget);

    await tester.tap(find.text('Pay Now'));
    await tester.pump();
    expect(find.text('Card number is required'), findsOneWidget);
    expect(find.text('Cardholder name is required'), findsOneWidget);
    expect(find.text('Expiry date is required'), findsOneWidget);
    expect(find.text('CVV is required'), findsOneWidget);
    expect(booking.events, isEmpty);

    final Finder sheetFields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(EditableText),
    );
    await tester.enterText(sheetFields.at(0), '1234567890123456');
    await tester.enterText(sheetFields.at(1), 'hala');
    await tester.enterText(sheetFields.at(2), '1228');
    await tester.pump();
    String textOf(int field) =>
        tester.widget<EditableText>(sheetFields.at(field)).controller.text;
    expect(textOf(0), '1234 5678 9012 3456');
    expect(textOf(1), 'HALA');
    expect(textOf(2), '12/28');
    // Still invalid (no CVV): nothing is sent.
    await tester.ensureVisible(find.text('Pay Now'));
    await tester.tap(find.text('Pay Now'));
    await tester.pump();
    expect(booking.events, isEmpty);
  });

  testWidgets('the card sheet fits a small Arabic phone at large text', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      locale: const Locale('ar'),
      size: const Size(320, 568),
      textScale: 1.35,
    );

    final Finder card = find.byType(CardPaymentMethod).first;
    await scrollTo(tester, card);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('promo: apply asks for the discount, remove clears it', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(find.text('Apply'), findsNothing);

    await tester.enterText(find.byType(EditableText).first, 'SAVE');
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pump();

    final GetPromoCodeDetail event = promo.events.single as GetPromoCodeDetail;
    expect(event.promoCode, 'SAVE');
    expect(event.totalPrice, '150');
    expect(copiedPromoCode?.promoCode, 'SAVE');

    promo.push(
      GetPromoCodeDetailSuccess(
        promoCodeDetail: NewPromoCodeModel(
          discountAmount: 50,
          totalPayAfterDiscount: 100,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('-50'), findsOneWidget);
    expect(find.text('100.0'), findsOneWidget);
    // The struck-through original beside the new total.
    expect(find.text('150'), findsWidgets);

    await tester.tap(find.text('Remove').first);
    await tester.pump();
    expect(promo.events.last, isA<ClearPromoCodeDetail>());
  });

  testWidgets('points above the balance show the limit and cannot be applied', (
    WidgetTester tester,
  ) async {
    await pump(tester);

    final Finder points = find.byType(EditableText).last;
    await scrollTo(tester, points);
    await tester.enterText(points, '500');
    await tester.pump();

    expect(
      find.textContaining('Points exceed available limit'),
      findsOneWidget,
    );
    expect(find.textContaining('You can only use up to 100'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
    await tester.tap(find.text('Apply'), warnIfMissed: false);
    await tester.pump();
    expect(GeneralSingleton().appliedPoints, 0);
  });

  testWidgets('back clears the order and promo state', (
    WidgetTester tester,
  ) async {
    GeneralSingleton().orderId = 'order-1';
    copiedPromoCode = CopyPromoCode(promoCode: 'SAVE', id: 'SAVE');
    await pump(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();

    expect(copiedPromoCode, isNull);
    expect(GeneralSingleton().orderId, isNull);
    expect(promo.events.last, isA<ClearPromoCodeDetail>());
  });
}
