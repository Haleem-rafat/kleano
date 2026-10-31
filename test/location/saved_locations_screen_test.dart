import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/design/adaptive_screen.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/kleano_theme.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/data/model/address_model.dart';
import 'package:thewasher/modules/booking/screens/saved_locations_screen.dart';

class _SpyLocationBloc extends LocationBloc {
  final List<LocationEvent> events = <LocationEvent>[];

  @override
  void add(LocationEvent event) => events.add(event);

  void push(LocationState state) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate delegate;
  late _SpyLocationBloc bloc;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    delegate = await LocalizationDelegate.create(
        fallbackLocale: 'en', supportedLocales: <String>['en', 'ar']);
  });

  setUp(() => bloc = _SpyLocationBloc());

  Future<void> pump(WidgetTester tester, List<AddressModel> locations) async {
    bloc.savedLocation = locations;
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
            child: const SavedLocationsScreen(),
          ),
        ),
      ),
    ));
    await tester.pump();
    bloc.push(GetSavedLocationSuccess(savedLocation: locations));
    await tester.pumpAndSettle();
  }

  final AddressModel work = AddressModel(
    sId: 'work',
    savedName: 'Work',
    streetName: 'Tahrir St',
    country: 'Egypt',
    isDefault: true,
  );
  final AddressModel gym = AddressModel(
    sId: 'gym',
    savedName: 'Gym',
    streetName: 'Corniche',
    country: 'Egypt',
    isDefault: false,
  );

  testWidgets('only a non-default address can be deleted, after confirming',
      (WidgetTester tester) async {
    await pump(tester, <AddressModel>[work, gym]);
    expect(bloc.events.single, isA<GetSavedLocation>());
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Tahrir St, Egypt'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.byType(KDialog), findsOneWidget);
    expect(bloc.events.whereType<DeleteLocationById>(), isEmpty);

    await tester.tap(find.text(translate('delete')).last);
    await tester.pumpAndSettle();
    expect(find.byType(KDialog), findsNothing);
    expect(bloc.events.whereType<DeleteLocationById>().single.locationId, 'gym');
  });

  testWidgets('tapping an address makes it the default',
      (WidgetTester tester) async {
    await pump(tester, <AddressModel>[work, gym]);
    await tester.tap(find.text('Gym'));
    await tester.pump();
    expect(bloc.events.whereType<SetDefaultLocation>().single.locationId, 'gym');
  });

  testWidgets('a nameless address falls back to its street',
      (WidgetTester tester) async {
    await pump(tester, <AddressModel>[
      AddressModel(sId: 'a', savedName: '', streetName: 'Corniche'),
    ]);
    expect(find.text('Corniche'), findsNWidgets(2));
  });
}
