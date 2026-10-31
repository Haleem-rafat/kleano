import 'package:thewasher/layout/services/local_notification_service.dart';
import 'package:thewasher/layout/services/notification_manager_service.dart';

class NotificationHelperService {
  static final NotificationHelperService _instance =
      NotificationHelperService._internal();
  factory NotificationHelperService() => _instance;
  NotificationHelperService._internal();

  final NotificationManagerService _notificationManager =
      NotificationManagerService();

  // Booking related notifications
  Future<void> notifyBookingConfirmed(
      String bookingId, String serviceName, DateTime scheduledTime) async {
    await _notificationManager.showBookingNotification(
      'Booking Confirmed',
      'Your $serviceName booking is confirmed for ${_formatDateTime(scheduledTime)}',
      payload: {
        'type': 'booking_confirmed',
        'bookingId': bookingId,
        'serviceName': serviceName,
        'scheduledTime': scheduledTime.toIso8601String(),
      },
    );
  }

  Future<void> notifyBookingCancelled(
      String bookingId, String serviceName) async {
    await _notificationManager.showBookingNotification(
      'Booking Cancelled',
      'Your $serviceName booking has been cancelled',
      payload: {
        'type': 'booking_cancelled',
        'bookingId': bookingId,
        'serviceName': serviceName,
      },
    );
  }

  Future<void> notifyBookingRescheduled(
      String bookingId, String serviceName, DateTime newTime) async {
    await _notificationManager.showBookingNotification(
      'Booking Rescheduled',
      'Your $serviceName booking has been rescheduled to ${_formatDateTime(newTime)}',
      payload: {
        'type': 'booking_rescheduled',
        'bookingId': bookingId,
        'serviceName': serviceName,
        'newTime': newTime.toIso8601String(),
      },
    );
  }

  Future<void> notifyBookingReminder(
      String bookingId, String serviceName, DateTime scheduledTime) async {
    await _notificationManager.showReminderNotification(
      'Upcoming Booking',
      'Your $serviceName booking is scheduled for ${_formatDateTime(scheduledTime)}',
      payload: {
        'type': 'booking_reminder',
        'bookingId': bookingId,
        'serviceName': serviceName,
        'scheduledTime': scheduledTime.toIso8601String(),
      },
    );
  }

  Future<void> notifyServiceProviderArrived(
      String bookingId, String providerName) async {
    await _notificationManager.showBookingNotification(
      'Service Provider Arrived',
      '$providerName has arrived at your location',
      payload: {
        'type': 'provider_arrived',
        'bookingId': bookingId,
        'providerName': providerName,
      },
    );
  }

  Future<void> notifyServiceCompleted(
      String bookingId, String serviceName) async {
    await _notificationManager.showBookingNotification(
      'Service Completed',
      'Your $serviceName has been completed successfully',
      payload: {
        'type': 'service_completed',
        'bookingId': bookingId,
        'serviceName': serviceName,
      },
    );
  }

  // Order related notifications
  Future<void> notifyOrderPlaced(String orderId, double amount) async {
    await _notificationManager.showOrderNotification(
      'Order Placed',
      'Your order has been placed successfully. Amount: \$${amount.toStringAsFixed(2)}',
      payload: {
        'type': 'order_placed',
        'orderId': orderId,
        'amount': amount,
      },
    );
  }

  Future<void> notifyOrderStatusUpdate(String orderId, String status) async {
    await _notificationManager.showOrderNotification(
      'Order Update',
      'Your order status has been updated to: $status',
      payload: {
        'type': 'order_status_update',
        'orderId': orderId,
        'status': status,
      },
    );
  }

  Future<void> notifyPaymentSuccess(String orderId, double amount) async {
    await _notificationManager.showOrderNotification(
      'Payment Successful',
      'Payment of \$${amount.toStringAsFixed(2)} has been processed successfully',
      payload: {
        'type': 'payment_success',
        'orderId': orderId,
        'amount': amount,
      },
    );
  }

  Future<void> notifyPaymentFailed(String orderId, String reason) async {
    await _notificationManager.showOrderNotification(
      'Payment Failed',
      'Payment failed: $reason',
      payload: {
        'type': 'payment_failed',
        'orderId': orderId,
        'reason': reason,
      },
    );
  }

  // Promotion and marketing notifications
  Future<void> notifySpecialOffer(
      String title, String description, String offerCode) async {
    await _notificationManager.showPromotionNotification(
      title,
      description,
      payload: {
        'type': 'special_offer',
        'offerCode': offerCode,
      },
    );
  }

  Future<void> notifyDiscountAvailable(
      String discount, String validUntil) async {
    await _notificationManager.showPromotionNotification(
      'Discount Available!',
      '$discount discount available until $validUntil',
      payload: {
        'type': 'discount_available',
        'discount': discount,
        'validUntil': validUntil,
      },
    );
  }

  Future<void> notifyNewService(String serviceName, String description) async {
    await _notificationManager.showPromotionNotification(
      'New Service Available',
      '$serviceName: $description',
      payload: {
        'type': 'new_service',
        'serviceName': serviceName,
        'description': description,
      },
    );
  }

  // System notifications
  Future<void> notifyMaintenance(String message, DateTime scheduledTime) async {
    await _notificationManager.showSystemNotification(
      'Scheduled Maintenance',
      message,
      payload: {
        'type': 'maintenance',
        'scheduledTime': scheduledTime.toIso8601String(),
      },
    );
  }

  Future<void> notifyAppUpdate(String version, String features) async {
    await _notificationManager.showSystemNotification(
      'App Update Available',
      'Update to version $version is available. New features: $features',
      payload: {
        'type': 'app_update',
        'version': version,
        'features': features,
      },
    );
  }

  Future<void> notifySystemAlert(String title, String message) async {
    await _notificationManager.showSystemNotification(
      title,
      message,
      payload: {
        'type': 'system_alert',
      },
    );
  }

  // Reminder notifications
  Future<void> scheduleBookingReminder(
      String bookingId, String serviceName, DateTime bookingTime) async {
    final reminderTime = bookingTime.subtract(const Duration(hours: 2));

    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationManager.scheduleReminder(
        'Booking Reminder',
        'Your $serviceName booking is in 2 hours',
        reminderTime,
        payload: {
          'type': 'booking_reminder',
          'bookingId': bookingId,
          'serviceName': serviceName,
          'bookingTime': bookingTime.toIso8601String(),
        },
        id: bookingId.hashCode,
      );
    }
  }

  Future<void> scheduleServiceReminder(
      String serviceName, DateTime nextServiceDate) async {
    final reminderTime = nextServiceDate.subtract(const Duration(days: 1));

    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationManager.scheduleReminder(
        'Service Reminder',
        'Time for your next $serviceName service',
        reminderTime,
        payload: {
          'type': 'service_reminder',
          'serviceName': serviceName,
          'nextServiceDate': nextServiceDate.toIso8601String(),
        },
        id: serviceName.hashCode,
      );
    }
  }

  Future<void> schedulePaymentReminder(
      String orderId, double amount, DateTime dueDate) async {
    final reminderTime = dueDate.subtract(const Duration(days: 1));

    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationManager.scheduleReminder(
        'Payment Reminder',
        'Payment of \$${amount.toStringAsFixed(2)} is due tomorrow',
        reminderTime,
        payload: {
          'type': 'payment_reminder',
          'orderId': orderId,
          'amount': amount,
          'dueDate': dueDate.toIso8601String(),
        },
        id: orderId.hashCode,
      );
    }
  }

  // General notifications
  Future<void> notifyWelcome(String userName) async {
    await _notificationManager.showLocalNotification(
      'Welcome to KleanO!',
      'Hi $userName, welcome to our cleaning service platform',
      NotificationType.general,
      payload: {
        'type': 'welcome',
        'userName': userName,
      },
    );
  }

  Future<void> notifyFeedbackRequest(String serviceName) async {
    await _notificationManager.showLocalNotification(
      'How was your service?',
      'Please rate your $serviceName experience',
      NotificationType.general,
      payload: {
        'type': 'feedback_request',
        'serviceName': serviceName,
      },
    );
  }

  Future<void> notifyAccountUpdate(String updateType) async {
    await _notificationManager.showLocalNotification(
      'Account Updated',
      'Your $updateType has been updated successfully',
      NotificationType.general,
      payload: {
        'type': 'account_update',
        'updateType': updateType,
      },
    );
  }

  // Utility methods
  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month $day, $year at $hour:$minute';
  }

  // Cancel specific reminder
  Future<void> cancelBookingReminder(String bookingId) async {
    await _notificationManager.cancelNotification(bookingId.hashCode);
  }

  Future<void> cancelServiceReminder(String serviceName) async {
    await _notificationManager.cancelNotification(serviceName.hashCode);
  }

  Future<void> cancelPaymentReminder(String orderId) async {
    await _notificationManager.cancelNotification(orderId.hashCode);
  }

  // Test notifications for development
  Future<void> testAllNotificationTypes() async {
    await notifyBookingConfirmed('test123', 'House Cleaning',
        DateTime.now().add(const Duration(hours: 2)));
    await notifyOrderPlaced('order123', 99.99);
    await notifySpecialOffer(
        'Summer Sale', 'Get 20% off on all services', 'SUMMER20');
    await notifySystemAlert('Test Alert', 'This is a test system notification');
    await notifyWelcome('Test User');
  }
}
