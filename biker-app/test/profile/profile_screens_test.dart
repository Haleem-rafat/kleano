import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_dialog.dart';
import 'package:thewhsherbiker/core/design/components/k_picker_field.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/components/k_text_field.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/screens/account_screen.dart';
import 'package:thewhsherbiker/modules/profile/screens/biker_schedule.dart';
import 'package:thewhsherbiker/modules/profile/screens/profile_screen.dart';
import 'package:thewhsherbiker/modules/profile/screens/settings_screen.dart';
import 'package:thewhsherbiker/modules/profile/screens/update_biker_data.dart';
import 'package:thewhsherbiker/modules/profile/widget/biker_status_switch.dart';

import '../home/home_test_support.dart';

void biker() {
  profile.profile = ProfileModel(
    status: 'ONLINE',
    userName: 'Haleem',
    phone: '+201012345678',
    createdAt: '11/9/2025',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setUpLanguages);
  setUp(setUpSpies);

  group('profile', () {
    testWidgets('sends what it always sent and logs out on tap', (
      WidgetTester t,
    ) async {
      t.view.devicePixelRatio = 3;
      t.view.physicalSize = const Size(375, 1400) * 3;
      addTearDown(t.view.reset);
      biker();
      await t.pumpWidget(app(const ProfileScreen(isTab: true)));
      await settle(t);
      expect(profile.sent[0], isA<BikerGetTotalWashes>());
      expect(profile.sent[1], isA<BikerGetTotalCommission>());

      await t.tap(find.widgetWithText(KButton, translate(AppStrings.logOut)));
      await settle(t);
      expect(auth.sent, isEmpty);
      await t.tap(
        find.descendant(
          of: find.byType(KDialog),
          matching: find.widgetWithText(KButton, translate(AppStrings.logOut)),
        ),
      );
      await settle(t);
      expect(auth.sent.single, isA<BikerLogOut>());
    });

    testWidgets('pushed, it can go back', (WidgetTester t) async {
      phone(t);
      biker();
      await t.pumpWidget(
        app(
          Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await settle(t);
      await t.tap(find.text('open'));
      await settle(t);
      expect(find.byType(GlassBackButton), findsOneWidget);
    });
  });

  group('online switch over the map', () {
    testWidgets('asks the backend and shows only what it confirmed', (
      WidgetTester t,
    ) async {
      phone(t);
      biker();
      await t.pumpWidget(
        app(const Scaffold(body: Center(child: BikerStatusSwitchWidget()))),
      );
      await settle(t);

      await t.tap(find.byType(Switch));
      await settle(t);
      expect((profile.sent.single as BikerUpdateStatus).status, 'OFFLINE');
      expect(t.widget<Switch>(find.byType(Switch)).value, isTrue);
    });
  });

  group('schedule', () {
    testWidgets(
      'loads; other profile states leave it alone; retry on failure',
      (WidgetTester t) async {
        phone(t);
        biker();
        await t.pumpWidget(app(const BikerSchedule()));
        await settle(t);
        expect(profile.sent.single, isA<BikerGetSchedule>());
        expect(find.byType(KSkeleton), findsOneWidget);

        profile.push(BikerGetScheduleFailed(error: 'No schedule data'));
        await settle(t);
        expect(find.byType(KErrorState), findsOneWidget);

        profile.push(BikerGetTotalWashesLoading());
        await settle(t);
        expect(find.byType(KErrorState), findsOneWidget);
      },
    );
  });

  group('forms', () {
    for (final String language in <String>['en', 'ar']) {
      testWidgets('$language: account, edit and settings fit a small phone', (
        WidgetTester t,
      ) async {
        phone(t, width: 320, height: 568);
        t.platformDispatcher.textScaleFactorTestValue = 1.35;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        await delegate.changeLocale(Locale(language));
        biker();

        await t.pumpWidget(app(const AccountScreen()));
        await settle(t);
        expect(t.takeException(), isNull);

        await t.pumpWidget(app(const UpdateBikerData()));
        await settle(t);
        expect(t.takeException(), isNull);
        expect(find.byType(KTextField), findsOneWidget);

        await t.pumpWidget(app(const SettingScreen()));
        await settle(t);
        expect(t.takeException(), isNull);
        expect(find.byType(KPickerField<String>), findsOneWidget);
      });
    }

    testWidgets('save sends the edit; a typed name wins', (
      WidgetTester t,
    ) async {
      phone(t);
      biker();
      await t.pumpWidget(app(const UpdateBikerData()));
      await settle(t);
      await t.enterText(find.byType(TextFormField), ' Sam ');
      await t.tap(find.byType(KButton));
      final BikerProfileEdit sent = profile.sent.single as BikerProfileEdit;
      expect(sent.name, 'Sam');
      expect(sent.image, '');
    });

    testWidgets('account shows the phone split into code and number', (
      WidgetTester t,
    ) async {
      phone(t);
      biker();
      await t.pumpWidget(app(const AccountScreen()));
      await settle(t);
      expect(find.textContaining('(+20) 1012345678'), findsOneWidget);
      expect(find.byType(KStatusChip), findsNothing);
    });
  });
}
