import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:thewasher/modules/notifications/screens/notifications_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

enum NotificationType {
  booking,
  reminder,
  promotion,
  general,
  order,
  system,
}

enum NotificationPriority {
  low,
  normal,
  high,
  max,
}

class NotificationData {
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic>? payload;
  final String? imageUrl;
  final int? id;

  NotificationData({
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.payload,
    this.imageUrl,
    this.id,
  });
}

class LocalNotificationServices {
  static final LocalNotificationServices _instance =
      LocalNotificationServices._internal();
  factory LocalNotificationServices() => _instance;
  LocalNotificationServices._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  BuildContext? _context;

  // Notification channels for Android
  static const String _bookingChannelId = 'booking_notifications';
  static const String _reminderChannelId = 'reminder_notifications';
  static const String _promotionChannelId = 'promotion_notifications';
  static const String _generalChannelId = 'general_notifications';
  static const String _orderChannelId = 'order_notifications';
  static const String _systemChannelId = 'system_notifications';

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    _context = context;

    try {
      // Android initialization
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@drawable/ic_notification');

      // iOS initialization
      const DarwinInitializationSettings darwinInitializationSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onSelectNotification,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      _isInitialized = true;
      debugPrint("✅ Local notifications initialized successfully");
    } catch (e) {
      debugPrint("❌ Error initializing local notifications: $e");
    }
  }

  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      final List<AndroidNotificationChannel> channels = [
        const AndroidNotificationChannel(
          _bookingChannelId,
          'Booking Notifications',
          description: 'Notifications for booking updates and status changes',
          importance: Importance.high,
          playSound: true,
        ),
        const AndroidNotificationChannel(
          _reminderChannelId,
          'Reminder Notifications',
          description: 'Notifications for appointment reminders',
          importance: Importance.high,
          playSound: true,
        ),
        const AndroidNotificationChannel(
          _promotionChannelId,
          'Promotion Notifications',
          description: 'Notifications for promotions and offers',
          importance: Importance.defaultImportance,
          playSound: false,
        ),
        const AndroidNotificationChannel(
          _generalChannelId,
          'General Notifications',
          description: 'General app notifications',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
        const AndroidNotificationChannel(
          _orderChannelId,
          'Order Notifications',
          description: 'Notifications for order updates',
          importance: Importance.high,
          playSound: true,
        ),
        const AndroidNotificationChannel(
          _systemChannelId,
          'System Notifications',
          description: 'System and maintenance notifications',
          importance: Importance.max,
          playSound: true,
        ),
      ];

      for (final channel in channels) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }
    }
  }

  void _onSelectNotification(NotificationResponse? response) {
    if (response == null || _context == null) return;

    try {
      // Handle different notification types
      debugPrint("📱 Notification tapped: ${response.payload}");

      // Navigate based on notification type
      switch (response.payload) {
        case 'booking':
          // Navigate to booking screen
          pushPage(_context!, const NotificationsScreen());
          break;
        case 'reminder':
          // Navigate to reminders or calendar
          pushPage(_context!, const NotificationsScreen());
          break;
        case 'promotion':
          // Navigate to promotions screen
          pushPage(_context!, const NotificationsScreen());
          break;
        case 'order':
          // Navigate to order details
          pushPage(_context!, const NotificationsScreen());
          break;
        default:
          // Default navigation to notifications screen
          pushPage(_context!, const NotificationsScreen());
      }
    } catch (e) {
      debugPrint("❌ Error handling notification tap: $e");
    }
  }

  // Show immediate notification
  Future<void> showNotification(NotificationData notificationData) async {
    if (!_isInitialized) {
      debugPrint("❌ Local notifications not initialized");
      return;
    }

    try {
      final notificationId = notificationData.id ??
          DateTime.now().millisecondsSinceEpoch % 2147483647;

      // Get channel ID based on notification type
      final channelId = _getChannelId(notificationData.type);

      // Android notification details
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        _getChannelName(notificationData.type),
        channelDescription: _getChannelDescription(notificationData.type),
        importance: _getImportance(notificationData.priority),
        priority: _getPriority(notificationData.priority),
        icon: '@drawable/ic_notification',
        playSound: notificationData.type != NotificationType.promotion,
        enableVibration: true,
        styleInformation: notificationData.imageUrl != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(notificationData.imageUrl!),
                largeIcon: FilePathAndroidBitmap(notificationData.imageUrl!),
              )
            : const BigTextStyleInformation(''),
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: notificationData.title,
        body: notificationData.body,
        notificationDetails: notificationDetails,
        payload: notificationData.payload != null
            ? notificationData.payload.toString()
            : notificationData.type.name,
      );

      debugPrint("✅ Local notification shown: ${notificationData.title}");
    } catch (e) {
      debugPrint("❌ Error showing notification: $e");
    }
  }

  // Schedule notification for future delivery
  Future<void> scheduleNotification(
    NotificationData notificationData,
    DateTime scheduledDate, {
    String? repeatInterval,
  }) async {
    if (!_isInitialized) {
      debugPrint("❌ Local notifications not initialized");
      return;
    }

    try {
      final notificationId = notificationData.id ??
          DateTime.now().millisecondsSinceEpoch % 2147483647;
      final channelId = _getChannelId(notificationData.type);

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        _getChannelName(notificationData.type),
        channelDescription: _getChannelDescription(notificationData.type),
        importance: _getImportance(notificationData.priority),
        priority: _getPriority(notificationData.priority),
        icon: '@drawable/ic_notification',
        playSound: notificationData.type != NotificationType.promotion,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: notificationData.title,
        body: notificationData.body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: notificationDetails,
        // Inexact needs no SCHEDULE_EXACT_ALARM permission (restricted on Android 14+).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: notificationData.payload != null
            ? notificationData.payload.toString()
            : notificationData.type.name,
        matchDateTimeComponents: repeatInterval != null
            ? _getDateTimeComponents(repeatInterval)
            : null,
      );

      debugPrint("✅ Notification scheduled for: $scheduledDate");
    } catch (e) {
      debugPrint("❌ Error scheduling notification: $e");
    }
  }

  // Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id: id);
      debugPrint("✅ Notification cancelled: $id");
    } catch (e) {
      debugPrint("❌ Error cancelling notification: $e");
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint("✅ All notifications cancelled");
    } catch (e) {
      debugPrint("❌ Error cancelling all notifications: $e");
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      debugPrint("❌ Error getting pending notifications: $e");
      return [];
    }
  }

  // Helper methods
  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return _bookingChannelId;
      case NotificationType.reminder:
        return _reminderChannelId;
      case NotificationType.promotion:
        return _promotionChannelId;
      case NotificationType.general:
        return _generalChannelId;
      case NotificationType.order:
        return _orderChannelId;
      case NotificationType.system:
        return _systemChannelId;
    }
  }

  String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return 'Booking Notifications';
      case NotificationType.reminder:
        return 'Reminder Notifications';
      case NotificationType.promotion:
        return 'Promotion Notifications';
      case NotificationType.general:
        return 'General Notifications';
      case NotificationType.order:
        return 'Order Notifications';
      case NotificationType.system:
        return 'System Notifications';
    }
  }

  String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return 'Notifications for booking updates and status changes';
      case NotificationType.reminder:
        return 'Notifications for appointment reminders';
      case NotificationType.promotion:
        return 'Notifications for promotions and offers';
      case NotificationType.general:
        return 'General app notifications';
      case NotificationType.order:
        return 'Notifications for order updates';
      case NotificationType.system:
        return 'System and maintenance notifications';
    }
  }

  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }

  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }

  DateTimeComponents? _getDateTimeComponents(String repeatInterval) {
    switch (repeatInterval.toLowerCase()) {
      case 'daily':
        return DateTimeComponents.time;
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'monthly':
        return DateTimeComponents.dayOfMonthAndTime;
      case 'yearly':
        return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }

  // Legacy method for backward compatibility
  Future<void> notification(
      {required String title, required String body}) async {
    final notificationData = NotificationData(
      title: title,
      body: body,
      type: NotificationType.general,
    );
    await showNotification(notificationData);
  }
}
