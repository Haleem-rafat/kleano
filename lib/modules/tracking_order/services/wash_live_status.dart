import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_card.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/functions/check_step_data.dart';

/// The wash in progress outside the app: Live Activity and Dynamic Island on
/// iOS, an ongoing notification with progress on Android.
class WashLiveStatus {
  WashLiveStatus._();

  static final WashLiveStatus instance = WashLiveStatus._();

  static const MethodChannel _ios = MethodChannel('kleano/live_activity');
  static const int _notificationId = 7401;
  static const String _androidChannel = 'wash_status';

  /// The order status a socket event announces; null for other events.
  static String? statusForEvent(String event) => switch (event) {
    AppConstants.orderAccepted => AppConstants.acceptedByBiker,
    AppConstants.orderOnTheWay => AppConstants.bikerOnTheWay,
    AppConstants.orderArrived => AppConstants.bikerArrived,
    AppConstants.orderOnWashing => AppConstants.onWashing,
    AppConstants.orderCompleted => AppConstants.completed,
    _ => null,
  };

  String? _orderId;
  String _vehicle = '';
  String _address = '';
  String? _status;
  bool _arabic = false;

  /// Called with the customer's active order, or null when there is none.
  Future<void> showOrder(OrderModel? order, {required bool arabic}) async {
    _arabic = arabic;
    if (order?.sId == null) return end();
    _orderId = order!.sId;
    _vehicle = <String?>[
      order.vehicle?.brand,
      order.vehicle?.model,
    ].where((String? part) => part?.isNotEmpty == true).join(' ');
    _address = order.location?.streetName ?? '';
    await _publish(order.status ?? '');
  }

  /// Called for every socket event, so a new stage shows without a reload.
  Future<void> onSocketEvent(String event, dynamic data) async {
    final String? status = statusForEvent(event);
    if (status == null || data is! Map || data['_id'] != _orderId) return;
    await _publish(status);
  }

  Future<void> end() async {
    _orderId = null;
    _status = null;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _ios.invokeMethod<void>('end');
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await FlutterLocalNotificationsPlugin().cancel(id: _notificationId);
      }
    } catch (e) {
      debugPrint('Live status not cleared: $e');
    }
  }

  Future<void> _publish(String status) async {
    if (status == _status) return;
    _status = status;
    final int step = getStepData(status).step;
    final String stage = MyBookingCard.statusText(status);
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _ios.invokeMethod<void>('show', <String, Object?>{
          'orderId': _orderId,
          'vehicle': _vehicle,
          'address': _address,
          'stage': stage,
          'step': step,
          'rtl': _arabic,
          'stageLabels': <String>[
            translate(AppStrings.onTheWay),
            translate(AppStrings.arrived),
            translate(AppStrings.washing),
            translate(AppStrings.completed),
          ],
        });
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await _showAndroid(stage, step);
      }
    } catch (e) {
      debugPrint('Live status not shown: $e');
    }
    if (step >= 3) {
      _orderId = null;
      _status = null;
    }
  }

  Future<void> _showAndroid(String stage, int step) {
    final bool done = step >= 3;
    return FlutterLocalNotificationsPlugin().show(
      id: _notificationId,
      title: _vehicle.isEmpty ? stage : '$stage · $_vehicle',
      body: _address,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel,
          translate(AppStrings.active),
          icon: '@drawable/ic_notification',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: !done,
          autoCancel: done,
          onlyAlertOnce: true,
          playSound: false,
          enableVibration: false,
          showWhen: false,
          showProgress: !done,
          maxProgress: 4,
          progress: step + 1,
          category: AndroidNotificationCategory.progress,
        ),
      ),
    );
  }
}
