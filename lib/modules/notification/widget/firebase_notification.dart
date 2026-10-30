import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Firebase Cloud Messaging Service
/// Handles FCM token management and message streaming
class FirebaseCloudMessagingService {
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  /// Get the initial message if app was opened from a notification
  static Future<RemoteMessage?> get getInitialMessage =>
      firebaseMessaging.getInitialMessage();

  /// Request notification permissions from the user
  /// Returns NotificationSettings with the user's response
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) {
    return firebaseMessaging.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );
  }

  /// Listen to foreground notifications (when app is open)
  /// These won't show a notification by default, you need to display them manually
  StreamSubscription<RemoteMessage> listenToForegroundNotifications(
    void Function(RemoteMessage) callback,
  ) {
    return FirebaseMessaging.onMessage.listen(callback);
  }

  /// Listen to background notifications (when app is in background and user taps notification)
  /// This fires when user opens the app by tapping a notification
  StreamSubscription<RemoteMessage> listenToBackgroundNotifications(
    void Function(RemoteMessage) callback,
  ) {
    return FirebaseMessaging.onMessageOpenedApp.listen(callback);
  }

  /// Get the FCM token for this device
  /// This token should be sent to your backend to send notifications to this device
  Future<String?> getFcmToken() async {
    try {
      final String? token = await firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Listen to token refresh
  /// This happens when the token is updated by FCM
  StreamSubscription<String> listenToTokenRefresh(
    void Function(String) callback,
  ) {
    return firebaseMessaging.onTokenRefresh.listen(callback);
  }

  /// Subscribe to a topic
  /// Useful for sending notifications to groups of users
  Future<void> subscribeToTopic(String topic) async {
    try {
      await firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Delete the FCM token
  /// Useful when user logs out
  Future<void> deleteToken() async {
    try {
      await firebaseMessaging.deleteToken();
      print('FCM Token deleted');
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }

  /// Set foreground notification presentation options for iOS
  /// This determines how notifications appear when app is in foreground on iOS
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }
}
