import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thewhsherbiker/modules/notification/screens/notification_screen.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// Background message handler - MUST be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}

/// Comprehensive notification service that handles both Firebase and Local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  BuildContext? _context;
  bool _initialized = false;
  String? _fcmToken;

  // Notification channel constants
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications';
  static const String _orderChannelId = 'order_notifications';
  static const String _orderChannelName = 'Order Notifications';
  static const String _orderChannelDescription =
      'Notifications for new orders and updates';

  /// Initialize notification services
  Future<void> initialize(BuildContext context) async {
    if (_initialized) return;

    _context = context;

    try {
      // Initialize Firebase Messaging
      await _initializeFirebaseMessaging();

      // Initialize Local Notifications
      await _initializeLocalNotifications();

      // Setup notification channels for Android
      await _createNotificationChannels();

      // Setup message handlers
      _setupMessageHandlers();

      _initialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((String newToken) {
        _fcmToken = newToken;
        print('FCM Token refreshed: $newToken');
        // TODO: Send token to your backend
      });
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request iOS permissions explicitly
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // High importance channel
      const AndroidNotificationChannel highImportanceChannel =
          AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      // Order notifications channel
      const AndroidNotificationChannel orderChannel =
          AndroidNotificationChannel(
        _orderChannelId,
        _orderChannelName,
        description: _orderChannelDescription,
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('neworder'),
        enableVibration: true,
        enableLights: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(highImportanceChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(orderChannel);

      print('✅ Android notification channels created');
    }
  }

  /// Setup message handlers for different notification states
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Got a message whilst in the FOREGROUND!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
          isOrderNotification: message.data['type'] == 'order',
        );
      }
    });

    // Handle notification opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notification opened from BACKGROUND');
      print('Message data: ${message.data}');
      _handleNotificationNavigation(message.data);
    });

    // Check for initial message (app opened from terminated state)
    _checkInitialMessage();
  }

  /// Check if app was opened from a notification
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      print('🚀 App opened from TERMINATED state via notification');
      print('Message data: ${initialMessage.data}');
      // Wait a bit for app to fully initialize
      await Future.delayed(const Duration(seconds: 1));
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    bool isOrderNotification = false,
  }) async {
    final String channelId = isOrderNotification ? _orderChannelId : _channelId;
    final String channelName =
        isOrderNotification ? _orderChannelName : _channelName;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
          isOrderNotification ? _orderChannelDescription : _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_notification',
      sound: isOrderNotification
          ? const RawResourceAndroidNotificationSound('neworder')
          : null,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'newOrder.wav',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped with payload: ${response.payload}');

    if (_context != null) {
      // Navigate to notification screen or specific screen based on payload
      pushPage(_context!, NotificationScreen());
    }
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (_context == null) return;

    final String? type = data['type'];
    final String? orderId = data['orderId'];

    switch (type) {
      case 'order':
        // Navigate to order details
        if (orderId != null) {
          // TODO: Navigate to specific order
          pushPage(_context!, NotificationScreen());
        }
        break;
      case 'message':
        // Navigate to messages
        pushPage(_context!, NotificationScreen());
        break;
      default:
        // Navigate to general notifications
        pushPage(_context!, NotificationScreen());
    }
  }

  /// Show a custom local notification (for testing or scheduled notifications)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    bool isOrderNotification = false,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload,
      isOrderNotification: isOrderNotification,
    );
  }

  /// Schedule a notification for a future time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Note: For scheduled notifications, you may want to use a different package
    // like flutter_local_notifications with timezone support or workmanager
    print('Scheduled notification for: $scheduledTime');
    // Implementation depends on your specific requirements
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final bool? result = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return false;
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  /// Update context (useful when context changes)
  void updateContext(BuildContext context) {
    _context = context;
  }
}
