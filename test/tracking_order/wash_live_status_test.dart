import 'package:flutter_test/flutter_test.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/modules/tracking_order/services/wash_live_status.dart';

void main() {
  test('every stage event maps to its order status', () {
    expect(
      WashLiveStatus.statusForEvent(AppConstants.orderOnTheWay),
      AppConstants.bikerOnTheWay,
    );
    expect(
      WashLiveStatus.statusForEvent(AppConstants.orderArrived),
      AppConstants.bikerArrived,
    );
    expect(
      WashLiveStatus.statusForEvent(AppConstants.orderOnWashing),
      AppConstants.onWashing,
    );
    expect(
      WashLiveStatus.statusForEvent(AppConstants.orderCompleted),
      AppConstants.completed,
    );
    expect(WashLiveStatus.statusForEvent(AppConstants.bikerMove), isNull);
  });
}
