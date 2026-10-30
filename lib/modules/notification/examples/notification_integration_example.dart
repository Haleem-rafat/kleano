/// NOTIFICATION INTEGRATION EXAMPLE
/// This file shows how to integrate the notification system into your app
/// DO NOT RUN THIS FILE - It's for reference only

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:thewhsherbiker/modules/notification/helpers/notification_helper.dart';
import 'package:thewhsherbiker/modules/notification/services/notification_service.dart';

/// ============================================================================
/// EXAMPLE 1: Initialize notifications in Home Screen
/// ============================================================================
class HomeScreenIntegrationExample extends StatefulWidget {
  @override
  State<HomeScreenIntegrationExample> createState() =>
      _HomeScreenIntegrationExampleState();
}

class _HomeScreenIntegrationExampleState
    extends State<HomeScreenIntegrationExample> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize the notification service
      await _notificationService.initialize(context);

      // Get and print FCM token
      String? fcmToken = _notificationService.fcmToken;
      print('FCM Token: $fcmToken');

      // TODO: Send token to your backend
      // await yourApiService.registerFCMToken(fcmToken);

      // Subscribe to topics (optional)
      await _notificationService.subscribeToTopic('all-bikers');

      // Check if notifications are enabled
      bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) {
        // Show dialog or snackbar to enable notifications
        _showEnableNotificationsDialog();
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  void _showEnableNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Notifications'),
        content: Text('Please enable notifications to receive order updates.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(child: Text('Home Screen')),
    );
  }
}

/// ============================================================================
/// EXAMPLE 2: Using NotificationHelper (Simpler approach)
/// ============================================================================
class SimpleNotificationExample extends StatefulWidget {
  @override
  State<SimpleNotificationExample> createState() =>
      _SimpleNotificationExampleState();
}

class _SimpleNotificationExampleState extends State<SimpleNotificationExample> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    // Initialize notifications using the helper
    await NotificationHelper.initialize(context);

    // Get FCM token
    String? token = NotificationHelper.getFCMToken();
    print('FCM Token: $token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showSimpleNotification,
              child: Text('Show Simple Notification'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showOrderNotification,
              child: Text('Show Order Notification'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkNotificationStatus,
              child: Text('Check Notification Status'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSimpleNotification() async {
    await NotificationHelper.showSimpleNotification(
      title: 'Hello!',
      body: 'This is a test notification',
      data: {'type': 'test'},
    );
  }

  Future<void> _showOrderNotification() async {
    await NotificationHelper.showOrderNotification(
      title: 'New Order!',
      body: 'You have a new order #12345',
      orderId: '12345',
    );
  }

  Future<void> _checkNotificationStatus() async {
    bool enabled = await NotificationHelper.areNotificationsEnabled();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(enabled
            ? 'Notifications are enabled ✓'
            : 'Notifications are disabled ✗'),
      ),
    );
  }
}

/// ============================================================================
/// EXAMPLE 3: Complete integration with existing HomeScreen structure
/// ============================================================================
///
/// To integrate into your existing HomeScreen, add this to initState:
///
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///
///   // ... existing code ...
///
///   // Initialize notifications
///   _initializeNotifications();
/// }
///
/// Future<void> _initializeNotifications() async {
///   await NotificationHelper.initialize(context);
///
///   // Get FCM token and send to backend
///   String? fcmToken = NotificationHelper.getFCMToken();
///   if (fcmToken != null) {
///     // TODO: Send to your backend API
///     // await NotificationRepo.registerFCMToken(fcmToken);
///     print('FCM Token registered: $fcmToken');
///   }
/// }
/// ```

/// ============================================================================
/// EXAMPLE 4: Handling notifications in Bloc
/// ============================================================================
///
/// Update your NotificationBloc's MakePushNotification event to use the new service:
///
/// ```dart
/// on<MakePushNotification>((event, emit) async {
///   try {
///     emit(MakePushNotificationLoading());
///
///     // Initialize the notification service
///     await NotificationHelper.initialize(event.context);
///
///     // Get FCM token
///     String? fcmToken = NotificationHelper.getFCMToken();
///
///     if (fcmToken != null) {
///       // Send token to backend
///       final bool success = await NotificationRepo.addFCMToken(fcmToken: fcmToken);
///
///       if (success) {
///         emit(MakePushNotificationSuccess());
///       } else {
///         emit(MakePushNotificationFailed(error: 'Failed to register FCM token'));
///       }
///     } else {
///       emit(MakePushNotificationFailed(error: 'Failed to get FCM token'));
///     }
///   } catch (e) {
///     emit(MakePushNotificationFailed(error: e.toString()));
///   }
/// });
/// ```

/// ============================================================================
/// EXAMPLE 5: Showing notifications when receiving foreground messages
/// ============================================================================
class ForegroundNotificationExample {
  static void setupForegroundNotifications(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.messageId}');

      if (message.notification != null) {
        // Check if it's an order notification
        bool isOrder = message.data['type'] == 'order';

        if (isOrder) {
          // Show order notification with custom sound
          NotificationHelper.showOrderNotification(
            title: message.notification!.title ?? 'New Order',
            body: message.notification!.body ?? '',
            orderId: message.data['orderId'],
          );
        } else {
          // Show regular notification
          NotificationHelper.showSimpleNotification(
            title: message.notification!.title ?? 'Notification',
            body: message.notification!.body ?? '',
            data: message.data,
          );
        }
      }
    });
  }
}

/// ============================================================================
/// EXAMPLE 6: Topic-based notifications
/// ============================================================================
class TopicNotificationExample {
  static Future<void> subscribeToTopics() async {
    // Subscribe to all bikers
    await NotificationHelper.subscribeToTopic('all-bikers');

    // Subscribe to region-specific topics
    await NotificationHelper.subscribeToTopic('region-north');

    // Subscribe to premium features
    await NotificationHelper.subscribeToTopic('premium-features');
  }

  static Future<void> unsubscribeFromTopics() async {
    // Unsubscribe when user logs out
    await NotificationHelper.unsubscribeFromTopic('all-bikers');
    await NotificationHelper.unsubscribeFromTopic('region-north');
    await NotificationHelper.unsubscribeFromTopic('premium-features');
  }
}

/// ============================================================================
/// EXAMPLE 7: Cleaning up on logout
/// ============================================================================
class LogoutExample {
  static Future<void> handleLogout() async {
    // Cancel all pending notifications
    await NotificationHelper.cancelAllNotifications();

    // Unsubscribe from all topics
    await NotificationHelper.unsubscribeFromTopic('all-bikers');

    // Optionally delete FCM token
    // Note: A new token will be generated on next login
    // await FirebaseMessaging.instance.deleteToken();

    // Clear other user data...
  }
}

/// ============================================================================
/// NOTES:
/// ============================================================================
/// 
/// 1. Always initialize notifications early in your app lifecycle
/// 2. Handle notification permissions properly
/// 3. Test all three states: foreground, background, terminated
/// 4. Use different notification channels for different types of notifications
/// 5. Always send FCM token to your backend for push notifications
/// 6. Handle token refresh by listening to FirebaseMessaging.onTokenRefresh
/// 7. Test with both Android and iOS devices
/// 8. Make sure custom sounds are properly added to native resources

