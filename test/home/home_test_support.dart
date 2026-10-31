import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/kleano_theme.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/home_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/orders_screen.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/data/model/total_commission_model.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// Records what Home sends and never reaches the socket or the backend. It
/// doesn't extend HomeBloc, whose fields open a socket client and audio player.
class SpyHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  SpyHomeBloc() : super(HomeInitial());

  final List<HomeEvent> sent = <HomeEvent>[];

  @override
  List<OrderModel> activeList = <OrderModel>[];
  @override
  List<OrderModel> completeList = <OrderModel>[];
  @override
  int completeTotalLength = 0;
  @override
  List<OrderModel> orderList = <OrderModel>[];
  @override
  OrderModel orderDetails = OrderModel();
  @override
  int orderStep = -1;
  @override
  int selected = 0;
  @override
  int dialogCount = 0;

  @override
  void add(HomeEvent event) => sent.add(event);

  void push(HomeState state) => emit(state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SpyProfileBloc extends ProfileBloc {
  final List<ProfileEvent> sent = <ProfileEvent>[];

  @override
  void add(ProfileEvent event) => sent.add(event);

  void push(ProfileState state) => emit(state);
}

class SpyNotificationBloc extends NotificationBloc {
  final List<NotificationEvent> sent = <NotificationEvent>[];

  @override
  void add(NotificationEvent event) => sent.add(event);

  void push(NotificationState state) => emit(state);
}

class SpyAuthBloc extends AuthBloc {
  final List<AuthEvent> sent = <AuthEvent>[];

  @override
  void add(AuthEvent event) => sent.add(event);
}

late LocalizationDelegate delegate;
late SpyHomeBloc home;
late SpyProfileBloc profile;
late SpyNotificationBloc notifications;
late SpyAuthBloc auth;

/// Rebuilds for a language change the way `lib/app.dart` does.
Widget app(Widget screen) => LocalizedApp(
  delegate,
  Builder(
    builder: (BuildContext context) {
      LocalizationProvider.of(context);
      return MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<NotificationBloc>.value(value: notifications),
          BlocProvider<ProfileBloc>.value(value: profile),
          BlocProvider<HomeBloc>.value(value: home),
        ],
        child: AdaptiveScreenUtil(
          builder: (_) => MaterialApp(
            theme: kleanoTheme(brightness: Brightness.light),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              delegate,
            ],
            supportedLocales: delegate.supportedLocales,
            locale: delegate.currentLocale,
            home: screen,
          ),
        ),
      );
    },
  ),
);

void phone(WidgetTester t, {double width = 375, double height = 812}) {
  t.view.devicePixelRatio = 3;
  t.view.physicalSize = Size(width, height) * 3;
  addTearDown(t.view.reset);
}

OrderModel order(String id, {String status = 'ACCEPTED_BY_BIKER'}) =>
    OrderModel(sId: id, status: status, isAssigned: false)
      ..startTime = DateTime(2026, 10, 31, 9, 30)
      ..createdAt = DateTime(2026, 10, 30);

void onlineWithStats() {
  profile.profile = ProfileModel(
    status: 'ONLINE',
    userName: 'Haleem',
    rating: 4.5,
    totalWashes: 120,
    totalCommission: TotalCommissionModel(
      today: CommissionPeriod(totalCommission: 15, ordersCount: 1),
      allTime: CommissionPeriod(totalCommission: 980, ordersCount: 120),
      allWeekends: CommissionPeriod(totalCommission: 200, ordersCount: 20),
    ),
  );
}

Future<void> pumpHome(WidgetTester t) async {
  await t.pumpWidget(app(const HomeScreen()));
  await settle(t);
}

Future<void> pumpOrders(
  WidgetTester t, {
  OrdersSegment segment = OrdersSegment.active,
}) async {
  final ValueNotifier<OrdersSegment> notifier = ValueNotifier<OrdersSegment>(
    segment,
  );
  addTearDown(notifier.dispose);
  await t.pumpWidget(app(OrdersScreen(segment: notifier)));
  await settle(t);
}

/// Loads translations once, before any test.
Future<void> setUpLanguages() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: <String>['en', 'ar'],
  );
}

/// Fresh spies in the service locator, in English.
Future<void> setUpSpies() async {
  await delegate.changeLocale(const Locale('en'));
  await sl.reset();
  home = SpyHomeBloc();
  profile = SpyProfileBloc();
  notifications = SpyNotificationBloc();
  auth = SpyAuthBloc();
  sl.registerSingleton<HomeBloc>(home);
  sl.registerSingleton<ProfileBloc>(profile);
  sl.registerSingleton<NotificationBloc>(notifications);
  sl.registerSingleton<AuthBloc>(auth);
}

/// `pumpAndSettle` never returns while a platform spinner is on screen.
Future<void> settle(WidgetTester t) async {
  await t.pump();
  for (int i = 0; i < 20; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void onlineStatsOnly() {
  final String? status = profile.profile.status;
  onlineWithStats();
  profile.profile.status = status;
}
