import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_segmented.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/utilis/enums.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_tabs.dart';

class _SpyMyBookingBloc extends MyBookingBloc {
  final List<MyBookingEvent> events = <MyBookingEvent>[];

  @override
  void add(MyBookingEvent event) => events.add(event);

  void push(MyBookingState state) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;
  late _SpyMyBookingBloc bloc;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: <String>['en', 'ar'],
    );
  });

  setUp(() {
    bloc = _SpyMyBookingBloc();
    AppShared.token = 'token';
    isGuestUser = false;
  });

  tearDown(() => AppShared.token = '');

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
            home: BlocProvider<MyBookingBloc>.value(
              value: bloc,
              child: const MyBookingMainTabsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('each segment asks for its own bookings', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(find.byType(KSegmented<int>), findsOneWidget);
    expect(bloc.events.last, isA<FetchMyBookingActive>());

    await tester.tap(find.text(translate(AppStrings.history)));
    await tester.pump();
    expect(bloc.events.last, isA<FetchMyBookingHistory>());

    await tester.tap(find.text(translate(AppStrings.schedule)));
    await tester.pump();
    expect(bloc.events.last, isA<FetchMyBookingScheduled>());
  });

  testWidgets('segments also switch on iOS', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pump(tester);
    await tester.tap(find.text(translate(AppStrings.history)));
    await tester.pump();
    expect(bloc.events.last, isA<FetchMyBookingHistory>());
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('loading, connection error and retry', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    bloc.push(const MyBookingState(myBookingStatus: RequestStatus.loading));
    await tester.pump();
    expect(find.byType(KSkeleton), findsOneWidget);

    bloc.push(
      const MyBookingState(myBookingStatus: RequestStatus.connectionError),
    );
    await tester.pump();
    final int before = bloc.events.length;
    await tester.tap(find.byKey(const ValueKey<String>('k-error-retry')));
    expect(bloc.events.length, before + 1);
    expect(bloc.events.last, isA<FetchMyBookingActive>());
  });
}
