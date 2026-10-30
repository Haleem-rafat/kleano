import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:thewasher/core/services/fcm_token.dart';

class FirebaseCloudMessagingService {
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future<RemoteMessage?> get getInitialMessage =>
      firebaseMessaging.getInitialMessage();

  Future<NotificationSettings> requestPermission() =>
      firebaseMessaging.requestPermission();

  StreamSubscription<RemoteMessage> listenToForegroundNotifications(
    void Function(RemoteMessage) callback,
  ) {
    debugPrint('listenToForegroundNotifications');
    return FirebaseMessaging.onMessage.listen(callback);
  }

  StreamSubscription<RemoteMessage> listenToBackgroundNotifications(
    void Function(RemoteMessage) callback,
  ) {
    debugPrint('listenToBackgroundNotifications');
    return FirebaseMessaging.onMessageOpenedApp.listen(callback);
  }

  Future<String?> getFcmToken() => FcmToken.get();
}
