import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thewasher/layout/services/firebase_cloud_messaging_service.dart';
import 'package:thewasher/layout/services/local_notification_service.dart';

class NotificationManagerService {
  static final NotificationManagerService _instance =
      NotificationManagerService._internal();
  factory NotificationManagerService() => _instance;
  NotificationManagerService._internal();

  final FirebaseCloudMessagingService _fcmService =
      FirebaseCloudMessagingService();
  final LocalNotificationServices _localNotificationService =
      LocalNotificationServices();

  bool _isInitialized = false;
  BuildContext? _context;

  // Stream subscriptions
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _backgroundSubscription;

  // Track recently shown notifications to prevent duplicates
  final Set<String> _recentlyShownMessageIds = {};
  static const int _maxRecentMessages = 50;

  // Notification preferences
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _bookingNotifications = true;
  bool _reminderNotifications = true;
  bool _promotionNotifications = true;
  bool _orderNotifications = true;
  bool _systemNotifications = true;

  // Getters for notification preferences
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get bookingNotifications => _bookingNotifications;
  bool get reminderNotifications => _reminderNotifications;
  bool get promotionNotifications => _promotionNotifications;
  bool get orderNotifications => _orderNotifications;
  bool get systemNotifications => _systemNotifications;

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    _context = context;

    try {
      // Initialize local notifications
      await _localNotificationService.initialize(context);

      // Initialize FCM
      await _initializeFCM();

      // Set up notification listeners
      _setupNotificationListeners();

      _isInitialized = true;
      print("✅ Notification Manager initialized successfully");
    } catch (e) {
      print("❌ Error initializing Notification Manager: $e");
    }
  }

  Future<void> _initializeFCM() async {
    try {
      // Request permissions
      final settings = await _fcmService.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        print("✅ FCM permissions granted");

        // Get FCM token
        final token = await _fcmService.getFcmToken();
        if (token != null) {
          print("✅ FCM Token: $token");
        }
      } else {
        print("❌ FCM permissions denied");
      }
    } catch (e) {
      print("❌ Error initializing FCM: $e");
    }
  }

  void _setupNotificationListeners() {
    // Cancel any existing subscriptions first to prevent duplicates
    _foregroundSubscription?.cancel();
    _backgroundSubscription?.cancel();

    // Listen to foreground messages
    _foregroundSubscription =
        _fcmService.listenToForegroundNotifications(_handleForegroundMessage);

    // Listen to background messages (when app is in background)
    _backgroundSubscription =
        _fcmService.listenToBackgroundNotifications(_handleBackgroundMessage);

    // Handle initial message (when app is opened from notification)
    FirebaseCloudMessagingService.getInitialMessage
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleInitialMessage(message);
      }
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print("📱 Received foreground message: ${message.messageId}");

    // Check if this message was already shown to prevent duplicates
    if (message.messageId != null &&
        _recentlyShownMessageIds.contains(message.messageId)) {
      print(
          "⚠️ Duplicate notification detected, skipping: ${message.messageId}");
      return;
    }

    // Show local notification when app is in foreground
    if (message.notification != null) {
      final notificationData = NotificationData(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
        type: _getNotificationTypeFromFCM(message),
        priority: _getNotificationPriority(message.data),
        payload: message.data,
      );

      _localNotificationService.showNotification(notificationData);

      // Track this message ID to prevent duplicates
      if (message.messageId != null) {
        _recentlyShownMessageIds.add(message.messageId!);
        // Keep the set from growing too large
        if (_recentlyShownMessageIds.length > _maxRecentMessages) {
          _recentlyShownMessageIds.remove(_recentlyShownMessageIds.first);
        }
      }
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print("📱 Received background message: ${message.messageId}");
    // Handle background message logic here
  }

  void _handleInitialMessage(RemoteMessage message) {
    print("📱 Received initial message: ${message.messageId}");
    // Handle initial message when app is opened from notification
    if (_context != null) {
      _navigateFromNotification(message);
    }
  }

  void _navigateFromNotification(RemoteMessage message) {
    // Navigate based on notification data
    final type = message.data['type'] ?? 'general';

    switch (type) {
      case 'booking':
        // Navigate to booking details
        break;
      case 'order':
        // Navigate to order details
        break;
      case 'promotion':
        // Navigate to promotions
        break;
      default:
        // Navigate to notifications screen
        break;
    }
  }

  NotificationType _getNotificationTypeFromFCM(RemoteMessage message) {
    final type = message.data['type'] ?? 'general';

    switch (type) {
      case 'booking':
        return NotificationType.booking;
      case 'reminder':
        return NotificationType.reminder;
      case 'promotion':
        return NotificationType.promotion;
      case 'order':
        return NotificationType.order;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.general;
    }
  }

  NotificationPriority _getNotificationPriority(Map<String, dynamic> data) {
    final priority = data['priority'] ?? 'normal';

    switch (priority) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      case 'max':
        return NotificationPriority.max;
      default:
        return NotificationPriority.normal;
    }
  }

  // Show local notification
  Future<void> showLocalNotification(
    String title,
    String body,
    NotificationType type, {
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? payload,
    String? imageUrl,
    int? id,
  }) async {
    if (!_notificationsEnabled) return;

    final notificationData = NotificationData(
      title: title,
      body: body,
      type: type,
      priority: priority,
      payload: payload,
      imageUrl: imageUrl,
      id: id,
    );

    await _localNotificationService.showNotification(notificationData);
  }

  // Schedule local notification
  Future<void> scheduleLocalNotification(
    String title,
    String body,
    NotificationType type,
    DateTime scheduledDate, {
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? payload,
    String? imageUrl,
    int? id,
    String? repeatInterval,
  }) async {
    if (!_notificationsEnabled) return;

    final notificationData = NotificationData(
      title: title,
      body: body,
      type: type,
      priority: priority,
      payload: payload,
      imageUrl: imageUrl,
      id: id,
    );

    await _localNotificationService.scheduleNotification(
      notificationData,
      scheduledDate,
      repeatInterval: repeatInterval,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotificationService.cancelNotification(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotificationService.cancelAllNotifications();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotificationService.getPendingNotifications();
  }

  // Notification preferences management
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    print("📱 Notifications ${enabled ? 'enabled' : 'disabled'}");
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    print("🔊 Sound ${enabled ? 'enabled' : 'disabled'}");
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    print("📳 Vibration ${enabled ? 'enabled' : 'disabled'}");
  }

  void setBookingNotifications(bool enabled) {
    _bookingNotifications = enabled;
    print("📅 Booking notifications ${enabled ? 'enabled' : 'disabled'}");
  }

  void setReminderNotifications(bool enabled) {
    _reminderNotifications = enabled;
    print("⏰ Reminder notifications ${enabled ? 'enabled' : 'disabled'}");
  }

  void setPromotionNotifications(bool enabled) {
    _promotionNotifications = enabled;
    print("🎉 Promotion notifications ${enabled ? 'enabled' : 'disabled'}");
  }

  void setOrderNotifications(bool enabled) {
    _orderNotifications = enabled;
    print("📦 Order notifications ${enabled ? 'enabled' : 'disabled'}");
  }

  void setSystemNotifications(bool enabled) {
    _systemNotifications = enabled;
    print("⚙️ System notifications ${enabled ? 'enabled' : 'disabled'}");
  }

  // Convenience methods for specific notification types
  Future<void> showBookingNotification(
    String title,
    String body, {
    Map<String, dynamic>? payload,
    int? id,
  }) async {
    if (!_bookingNotifications) return;

    await showLocalNotification(
      title,
      body,
      NotificationType.booking,
      priority: NotificationPriority.high,
      payload: payload,
      id: id,
    );
  }

  Future<void> showReminderNotification(
    String title,
    String body, {
    Map<String, dynamic>? payload,
    int? id,
  }) async {
    if (!_reminderNotifications) return;

    await showLocalNotification(
      title,
      body,
      NotificationType.reminder,
      priority: NotificationPriority.high,
      payload: payload,
      id: id,
    );
  }

  Future<void> showPromotionNotification(
    String title,
    String body, {
    Map<String, dynamic>? payload,
    String? imageUrl,
    int? id,
  }) async {
    if (!_promotionNotifications) return;

    await showLocalNotification(
      title,
      body,
      NotificationType.promotion,
      priority: NotificationPriority.normal,
      payload: payload,
      imageUrl: imageUrl,
      id: id,
    );
  }

  Future<void> showOrderNotification(
    String title,
    String body, {
    Map<String, dynamic>? payload,
    int? id,
  }) async {
    if (!_orderNotifications) return;

    await showLocalNotification(
      title,
      body,
      NotificationType.order,
      priority: NotificationPriority.high,
      payload: payload,
      id: id,
    );
  }

  Future<void> showSystemNotification(
    String title,
    String body, {
    Map<String, dynamic>? payload,
    int? id,
  }) async {
    if (!_systemNotifications) return;

    await showLocalNotification(
      title,
      body,
      NotificationType.system,
      priority: NotificationPriority.max,
      payload: payload,
      id: id,
    );
  }

  // Schedule reminder
  Future<void> scheduleReminder(
    String title,
    String body,
    DateTime scheduledDate, {
    Map<String, dynamic>? payload,
    int? id,
    String? repeatInterval,
  }) async {
    if (!_reminderNotifications) return;

    await scheduleLocalNotification(
      title,
      body,
      NotificationType.reminder,
      scheduledDate,
      priority: NotificationPriority.high,
      payload: payload,
      id: id,
      repeatInterval: repeatInterval,
    );
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _fcmService.getFcmToken();
  }

  // Dispose
  void dispose() {
    _foregroundSubscription?.cancel();
    _backgroundSubscription?.cancel();
    _recentlyShownMessageIds.clear();
    _isInitialized = false;
    print("✅ Notification Manager disposed");
  }
}
