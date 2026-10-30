// Notification Integration Guide
// This file provides examples of how to integrate the notification system into your app

import 'package:flutter/material.dart';
import 'package:thewasher/layout/services/notification_manager_service.dart';
import 'package:thewasher/layout/services/notification_helper_service.dart';

class NotificationIntegrationGuide {
  // Example 1: Initialize notifications in your main app
  static Future<void> initializeNotifications(BuildContext context) async {
    final notificationManager = NotificationManagerService();
    await notificationManager.initialize(context);
  }

  // Example 2: Show a booking confirmation notification
  static Future<void> showBookingConfirmation(
      String bookingId, String serviceName, DateTime scheduledTime) async {
    final notificationHelper = NotificationHelperService();
    await notificationHelper.notifyBookingConfirmed(
        bookingId, serviceName, scheduledTime);
  }

  // Example 3: Schedule a reminder notification
  static Future<void> scheduleServiceReminder(
      String serviceName, DateTime nextServiceDate) async {
    final notificationHelper = NotificationHelperService();
    await notificationHelper.scheduleServiceReminder(
        serviceName, nextServiceDate);
  }

  // Example 4: Show a promotion notification
  static Future<void> showPromotion(
      String title, String description, String offerCode) async {
    final notificationHelper = NotificationHelperService();
    await notificationHelper.notifySpecialOffer(title, description, offerCode);
  }

  // Example 5: Handle notification preferences
  static void configureNotificationPreferences() {
    final notificationManager = NotificationManagerService();

    // Enable/disable different notification types
    notificationManager.setBookingNotifications(true);
    notificationManager.setReminderNotifications(true);
    notificationManager.setPromotionNotifications(false); // User opted out
    notificationManager.setOrderNotifications(true);
    notificationManager.setSystemNotifications(true);
  }

  // Example 6: Cancel specific notifications
  static Future<void> cancelBookingReminder(String bookingId) async {
    final notificationHelper = NotificationHelperService();
    await notificationHelper.cancelBookingReminder(bookingId);
  }

  // Example 7: Get pending notifications
  static Future<void> checkPendingNotifications() async {
    final notificationManager = NotificationManagerService();
    final pendingNotifications =
        await notificationManager.getPendingNotifications();
    debugPrint('Pending notifications: ${pendingNotifications.length}');
  }

  // Example 8: Integration in booking flow
  static Future<void> handleBookingFlow(
      String bookingId, String serviceName, DateTime scheduledTime) async {
    final notificationHelper = NotificationHelperService();

    // 1. Confirm booking
    await notificationHelper.notifyBookingConfirmed(
        bookingId, serviceName, scheduledTime);

    // 2. Schedule reminder (2 hours before)
    await notificationHelper.scheduleBookingReminder(
        bookingId, serviceName, scheduledTime);

    // 3. Schedule next service reminder (if applicable)
    final nextServiceDate = scheduledTime.add(const Duration(days: 30));
    await notificationHelper.scheduleServiceReminder(
        serviceName, nextServiceDate);
  }

  // Example 9: Integration in order flow
  static Future<void> handleOrderFlow(String orderId, double amount) async {
    final notificationHelper = NotificationHelperService();

    // 1. Order placed
    await notificationHelper.notifyOrderPlaced(orderId, amount);

    // 2. Payment success
    await notificationHelper.notifyPaymentSuccess(orderId, amount);

    // 3. Order status update
    await notificationHelper.notifyOrderStatusUpdate(orderId, 'Processing');
  }

  // Example 10: User onboarding
  static Future<void> handleUserOnboarding(String userName) async {
    final notificationHelper = NotificationHelperService();
    await notificationHelper.notifyWelcome(userName);
  }
}

// Integration Steps:
/*
1. Initialize the notification system in your main app:
   - Call NotificationManagerService().initialize(context) in your main app widget
   - This should be done early in the app lifecycle

2. Add notification permissions:
   - The system will automatically request permissions
   - Handle permission denied scenarios gracefully

3. Integrate in your business logic:
   - Use NotificationHelperService for common scenarios
   - Use NotificationManagerService for custom notifications

4. Add notification settings UI:
   - Use NotificationSettingsWidget in your settings screen
   - Allow users to customize their notification preferences

5. Handle notification taps:
   - The system automatically navigates based on notification type
   - Customize navigation logic in LocalNotificationServices._onSelectNotification

6. Test thoroughly:
   - Use NotificationDemoScreen for testing
   - Test on both Android and iOS
   - Test with app in foreground, background, and killed states

7. Consider battery optimization:
   - Don't send too many notifications
   - Use appropriate priorities
   - Allow users to disable notifications they don't want

8. Monitor and analytics:
   - Track notification delivery rates
   - Monitor user engagement with notifications
   - Use notification data for business insights
*/
