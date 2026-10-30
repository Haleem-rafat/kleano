import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Fetches the FCM registration token used by the backend for pushes.
///
/// On iOS the FCM token only exists after APNs hands over its device token,
/// so this waits for it (up to [apnsWait]) instead of failing.
///
/// firebase_messaging 17 deprecates `getToken()` in favour of FID-based
/// `register()`/`onRegistered`. Moving to FIDs needs the backend to send to
/// FIDs, so the classic token stays until that migration is done.
class FcmToken {
  FcmToken._();

  static Future<String?> get({
    Duration apnsWait = const Duration(seconds: 10),
  }) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      if (Platform.isIOS) {
        final DateTime deadline = DateTime.now().add(apnsWait);
        while (await messaging.getAPNSToken() == null &&
            DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
      // ignore: deprecated_member_use
      return await messaging.getToken();
    } catch (e) {
      debugPrint('FCM token unavailable: $e');
      return null;
    }
  }
}
