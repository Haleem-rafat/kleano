import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/order/widgets/photo_source_sheet.dart';
import 'package:thewhsherbiker/modules/order/widgets/status_order_bottom_sheet.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';

import '../home/home_test_support.dart';

class FakePicker extends ImagePickerPlatform {
  FakePicker(this.path);

  final String? path;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    // The real picker stays open for seconds: the sheet has long closed.
    await Future<void>.delayed(const Duration(seconds: 2));
    return path == null ? null : XFile(path!);
  }
}

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

Future<void> pick(WidgetTester t, int row) async {
  final PhotoSourceSheet sheet = t.widget(find.byType(PhotoSourceSheet));
  row == 0 ? sheet.onGallery() : sheet.onCamera();
  await t.pump(const Duration(seconds: 1));
  await t.pump(const Duration(seconds: 3));
  await settle(t);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setUpLanguages);
  setUp(() async {
    await setUpSpies();
    ImagePickerPlatform.instance = FakePicker('/tmp/wash.jpg');
  });

  for (final int row in <int>[0, 1]) {
    final String source = row == 0 ? 'gallery' : 'camera';

    testWidgets('start washing from the $source sends the event', (
      WidgetTester t,
    ) async {
      await pumpPanel(t, 'BIKER_ARRIVED', 1);
      await t.tap(find.text('Done'));
      await settle(t);
      await pick(t, row);
      final BikerOnWashingOrder event = home.sent
          .whereType<BikerOnWashingOrder>()
          .single;
      expect(event.beforeWashImagePath, '/tmp/wash.jpg');
      expect(find.byType(PhotoSourceSheet), findsNothing);
    });

    testWidgets('complete wash from the $source sends the event', (
      WidgetTester t,
    ) async {
      await pumpPanel(t, 'ON_WASHING', 2);
      await t.tap(find.text('Complete Wash'));
      await settle(t);
      await pick(t, row);
      final BikerCompleteOrder event = home.sent
          .whereType<BikerCompleteOrder>()
          .single;
      expect(event.afterWashImagePath, '/tmp/wash.jpg');
    });
  }

  testWidgets('cancelling the picker sends nothing', (WidgetTester t) async {
    ImagePickerPlatform.instance = FakePicker(null);
    await pumpPanel(t, 'ON_WASHING', 2);
    await t.tap(find.text('Complete Wash'));
    await settle(t);
    await pick(t, 0);
    expect(home.sent.whereType<BikerCompleteOrder>(), isEmpty);
  });
}
