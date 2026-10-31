import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/screens/home_screen.dart';
import 'package:thewasher/modules/splash/address_check_screen.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.body);

  final int status;
  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString(jsonEncode(body), status,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          });

  @override
  void close({bool force = false}) {}
}

Future<LocationState> _fetch(int status, Map<String, dynamic> body) async {
  ApiService.dio.httpClientAdapter = _Adapter(status, body);
  final LocationBloc bloc = LocationBloc();
  final Future<LocationState> done = bloc.stream.firstWhere(
    (LocationState s) =>
        s is GetSavedLocationSuccess || s is GetSavedLocationFailed,
  );
  bloc.add(GetSavedLocation());
  final LocationState state = await done;
  await bloc.close();
  return state;
}

/// Lets a test drive the screen with a chosen outcome and count fetches.
class _FakeLocationBloc extends LocationBloc {
  int fetches = 0;

  @override
  void add(LocationEvent event) {
    if (event is GetSavedLocation) fetches++;
  }

  void push(LocationState state) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
        fallbackLocale: 'en', supportedLocales: <String>['en', 'ar']);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppShared.token = '';
  });

  group('GetSavedLocation', () {
    test('no addresses is a success with an empty list, not a failure',
        () async {
      for (final Map<String, dynamic> body in <Map<String, dynamic>>[
        <String, dynamic>{'success': true, 'data': <dynamic>[]},
        <String, dynamic>{'success': true, 'data': null},
      ]) {
        final LocationState state = await _fetch(200, body);
        expect(state, isA<GetSavedLocationSuccess>());
        expect((state as GetSavedLocationSuccess).savedLocation, isEmpty);
      }
    });

    test('a server error stays a failure', () async {
      expect(await _fetch(500, <String, dynamic>{'success': false}),
          isA<GetSavedLocationFailed>());
    });

    test('an address with missing optional text still loads', () async {
      final LocationState state = await _fetch(200, <String, dynamic>{
        'success': true,
        'data': <dynamic>[
          <String, dynamic>{
            '_id': 'a',
            'latitude': 24.7,
            'longitude': 46,
            'isDefault': true,
          },
        ],
      });
      expect(state, isA<GetSavedLocationSuccess>());
      expect((state as GetSavedLocationSuccess).savedLocation, hasLength(1));
    });
  });

  group('AddressCheckScreen', () {
    late _FakeLocationBloc bloc;

    setUp(() {
      bloc = _FakeLocationBloc();
      sl.registerSingleton<LocationBloc>(bloc);
    });

    tearDown(() => sl.reset());

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(LocalizedApp(
        delegate,
        AdaptiveScreenUtil(
          builder: (_) => MaterialApp(
            theme: kleanoTheme(brightness: Brightness.light),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[delegate],
            supportedLocales: delegate.supportedLocales,
            locale: delegate.currentLocale,
            home: BlocProvider<LocationBloc>.value(
              value: bloc,
              child: const AddressCheckScreen(),
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets('a failed check offers retry and never opens the map',
        (WidgetTester tester) async {
      await pump(tester);
      expect(bloc.fetches, 1);

      bloc.push(GetSavedLocationFailed(error: 'timeout'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(HomeScreen), findsNothing);
      await tester.tap(find.byKey(const ValueKey<String>('k-error-retry')));
      await tester.pump();
      expect(bloc.fetches, 2);

      // The retry goes back to the checking state, so its result is shown too.
      expect(find.byKey(const ValueKey<String>('k-error-retry')), findsNothing);
    });
  });
}
