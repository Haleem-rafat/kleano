import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thewhsherbiker/modules/notification/screens/notification_screen.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// Enhanced Local Notification Service with custom channels and sound support
class LocalNotificationServices {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late AndroidInitializationSettings androidInitializationSettings;
  late DarwinInitializationSettings iosInitializationSettings;
  late InitializationSettings initializationSettings;
  BuildContext context;

  // Notification channel IDs
  static const String defaultChannelId = 'default_channel';
  static const String orderChannelId = 'order_channel';
  static const String highImportanceChannelId = 'high_importance_channel';

  LocalNotificationServices({required this.context});

  /// Initialize local notifications with custom channels
  Future<void> initializing() async {
    androidInitializationSettings =
        const AndroidInitializationSettings('@drawable/ic_notification');

    iosInitializationSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // Request iOS permissions
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Default channel
    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
      defaultChannelId,
      'Default Notifications',
      description: 'General app notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Order channel with custom sound
    const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      orderChannelId,
      'Order Notifications',
      description: 'New order and order update notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('neworder'),
      enableVibration: true,
      enableLights: true,
    );

    // High importance channel
    const AndroidNotificationChannel highImportanceChannel =
        AndroidNotificationChannel(
      highImportanceChannelId,
      'High Priority Notifications',
      description: 'High priority notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(orderChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);
  }

  /// Request iOS notification permissions
  Future<void> _requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print("onDidReceiveLocalNotification: $title - $body");
  }

  void onSelectNotification(NotificationResponse? payLoad) {
    print("Notification tapped with payload: ${payLoad?.payload}");

    if (payLoad != null && payLoad.payload != null) {
      // Handle different notification types based on payload
      _handleNotificationPayload(payLoad.payload!);
    } else {
      pushPage(context, NotificationScreen());
    }
  }

  /// Handle notification payload for routing
  void _handleNotificationPayload(String payload) {
    try {
      // You can parse the payload as JSON if needed
      // For now, just navigate to notification screen
      pushPage(context, NotificationScreen());
    } catch (e) {
      print("Error handling notification payload: $e");
      pushPage(context, NotificationScreen());
    }
  }

  /// Show notification with default channel
  Future<void> notification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      body: body,
      payload: payload,
      channelId: defaultChannelId,
      channelName: 'Default Notifications',
    );
  }

  /// Show order notification with custom sound
  Future<void> orderNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      body: body,
      payload: payload,
      channelId: orderChannelId,
      channelName: 'Order Notifications',
      playCustomSound: true,
    );
  }

  /// Show high importance notification
  Future<void> highImportanceNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      body: body,
      payload: payload,
      channelId: highImportanceChannelId,
      channelName: 'High Priority Notifications',
      fullScreenIntent: true,
    );
  }

  /// Internal method to show notification
  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
    required String channelId,
    required String channelName,
    bool playCustomSound = false,
    bool fullScreenIntent = false,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      priority: Priority.max,
      importance: Importance.max,
      fullScreenIntent: fullScreenIntent,
      icon: '@drawable/ic_notification',
      sound: playCustomSound
          ? const RawResourceAndroidNotificationSound('neworder')
          : null,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'newOrder.wav',
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
