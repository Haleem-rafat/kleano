import 'package:flutter/material.dart';
import 'package:thewhsherbiker/modules/notification/services/notification_service.dart';
import 'package:thewhsherbiker/modules/notification/widget/local_notification.dart';

/// Notification Helper
/// Provides easy-to-use methods for showing different types of notifications
class NotificationHelper {
  static final NotificationService _notificationService = NotificationService();

  /// Initialize notification services
  /// Call this once when the app starts, preferably after user logs in
  static Future<void> initialize(BuildContext context) async {
    await _notificationService.initialize(context);
  }

  /// Update context when it changes (e.g., after navigation)
  static void updateContext(BuildContext context) {
    _notificationService.updateContext(context);
  }

  /// Show a simple notification
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: data?.toString(),
    );
  }

  /// Show an order notification with custom sound
  static Future<void> showOrderNotification({
    required String title,
    required String body,
    String? orderId,
  }) async {
    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: orderId,
      isOrderNotification: true,
    );
  }

  /// Get FCM token
  static String? getFCMToken() {
    return _notificationService.fcmToken;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
  }

  /// Subscribe to a topic (useful for targeting specific user groups)
  static Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }

  /// Show local notification using the legacy service
  /// This is kept for backward compatibility
  static Future<void> showLocalNotification({
    required BuildContext context,
    required String title,
    required String body,
    String? payload,
    bool isOrderNotification = false,
  }) async {
    final LocalNotificationServices localNotificationService =
        LocalNotificationServices(context: context);

    if (isOrderNotification) {
      await localNotificationService.orderNotification(
        title: title,
        body: body,
        payload: payload,
      );
    } else {
      await localNotificationService.notification(
        title: title,
        body: body,
        payload: payload,
      );
    }
  }
}
