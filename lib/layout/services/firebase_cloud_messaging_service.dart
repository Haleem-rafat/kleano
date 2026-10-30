import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseCloudMessagingService {
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future<RemoteMessage?> get getInitialMessage =>
      firebaseMessaging.getInitialMessage();

  Future<NotificationSettings> requestPermission() =>
      firebaseMessaging.requestPermission();

  StreamSubscription<RemoteMessage> listenToForegroundNotifications(
    void Function(RemoteMessage) callback,
  ) {
    print('listenToForegroundNotifications');
    return FirebaseMessaging.onMessage.listen(callback);
  }

  StreamSubscription<RemoteMessage> listenToBackgroundNotifications(
    void Function(RemoteMessage) callback,
  ) {
    print('listenToBackgroundNotifications');
    return FirebaseMessaging.onMessageOpenedApp.listen(callback);
  }

  Future<String?> getFcmToken() async {
    if (Platform.isIOS) {
      final apnsToken = await firebaseMessaging.getAPNSToken();
      if (apnsToken == null) {
        print('⚠️ APNs token not set yet. Retrying...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    final fcmToken = await firebaseMessaging.getToken();
    print('✅ FCM Token: $fcmToken');
    return fcmToken;
  }
}
