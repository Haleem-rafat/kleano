# iOS Notification Setup Guide

This guide will help you fix local notifications on iOS for the Kleano Biker app.

## ✅ What's Already Done

1. ✅ **AppDelegate.swift** - Updated with proper notification handling
2. ✅ **Info.plist** - Has `UIBackgroundModes` with `remote-notification`
3. ✅ **Runner.entitlements** - Has `aps-environment` set to development
4. ✅ **Firebase configured** - FirebaseMessaging imported and initialized

## 🔧 Required Manual Steps

### Step 1: Add Sound File to Xcode Project

The notification sound file exists at `assets/audio/newOrder.wav` but needs to be added to the iOS project.

**Instructions:**

1. Open your project in Xcode:
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. In Xcode, **right-click on the `Runner` folder** (in the left sidebar)

3. Select **"Add Files to Runner..."**

4. Navigate to: `Kleano-Biker-Flutter/assets/audio/`

5. Select `newOrder.wav`

6. **Important**: Make sure these options are checked:
   - ✅ **"Copy items if needed"**
   - ✅ **"Create groups"** (not "Create folder references")
   - ✅ **Add to targets: Runner** (checkbox should be checked)

7. Click **"Add"**

8. Verify the file appears in:
   - Xcode Project Navigator (left sidebar) under Runner
   - Target settings: Select Runner target → Build Phases → Copy Bundle Resources
   - The file `newOrder.wav` should be listed there

### Step 2: Add Push Notification Capability

1. In Xcode, select the **Runner** project (top of the left sidebar)

2. Select the **Runner** target (under TARGETS)

3. Go to **Signing & Capabilities** tab

4. Click **"+ Capability"** button

5. Search for and add **"Push Notifications"**

6. You should see "Push Notifications" appear in the capabilities list

### Step 3: Update Entitlements for Production (Optional)

If you're building for production:

1. Open `ios/Runner/Runner.entitlements`

2. Change `aps-environment` from `development` to `production`:
   ```xml
   <key>aps-environment</key>
   <string>production</string>
   ```

   **Note**: For development builds, keep it as `development`

### Step 4: Clean Build and Reinstall

1. In Xcode, clean the build:
   - Menu: **Product** → **Clean Build Folder** (⇧⌘K)

2. Delete the app from your iOS device/simulator

3. Run the app again:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   flutter run
   ```

## 📱 Testing Notifications on iOS

### Test Local Notifications

Add this test code in your Flutter app:

```dart
import 'package:thewhsherbiker/modules/notification/helpers/notification_helper.dart';

// In a button or initState
await NotificationHelper.showSimpleNotification(
  title: 'Test Notification',
  body: 'This is a test from iOS!',
);

// Test order notification with sound
await NotificationHelper.showOrderNotification(
  title: 'New Order!',
  body: 'You have a new order #12345',
  orderId: '12345',
);
```

### Test Push Notifications (FCM)

1. Get your FCM token from the console logs
2. Use Firebase Console → Cloud Messaging → Send test message
3. Paste your FCM token
4. Send the notification

### Check Notification Permissions

```dart
bool enabled = await NotificationHelper.areNotificationsEnabled();
print('Notifications enabled: $enabled');
```

## 🐛 Troubleshooting

### Notifications Not Showing

1. **Check permissions**:
   - Settings → [Your App] → Notifications
   - Ensure "Allow Notifications" is ON

2. **Check the console logs**:
   - Look for "Firebase registration token:"
   - Look for any error messages about notifications

3. **Verify sound file**:
   - In Xcode: Runner target → Build Phases → Copy Bundle Resources
   - `newOrder.wav` should be listed

4. **Check app is in foreground**:
   - iOS doesn't show notification banners when app is in foreground by default
   - The notification sound should still play
   - Try putting app in background and sending notification

### Sound Not Playing

1. **Check file format**:
   - Must be `.wav`, `.aiff`, or `.caf`
   - Must be 30 seconds or less
   - Linear PCM or IMA4 format

2. **Check device volume**:
   - Make sure device is not on silent mode
   - Check notification volume in Settings

3. **Verify file is copied**:
   - Run the app from Xcode
   - Check Build Phases → Copy Bundle Resources

### APNs Certificate Issues

If you get APNs-related errors:

1. Ensure you have a valid Apple Developer account
2. Check your provisioning profile includes Push Notifications
3. For development: Use the development APNs certificate
4. For production: Use the production APNs certificate

## 📝 Additional Notes

### Background Notifications

The app is configured to handle:
- ✅ Foreground notifications (app is open)
- ✅ Background notifications (app in background, tapped notification)
- ✅ Terminated notifications (app was closed, tapped notification)

### Notification Channels

iOS doesn't use channels like Android, but we have equivalent settings:
- Alert type notifications with sound
- Order notifications with custom sound
- Badge updates
- Notification actions (coming soon)

### Firebase Cloud Messaging

The FCM token is automatically:
- Generated when app launches
- Sent to backend on login
- Refreshed when needed
- Logged to console for debugging

## ✨ What Was Fixed in AppDelegate.swift

The following was added to properly handle notifications:

1. **Import FirebaseMessaging**
2. **Register for notifications** with proper authorization
3. **Set notification delegate** to handle foreground notifications
4. **Set Messaging delegate** to receive FCM token
5. **Handle APNS token** registration
6. **Handle registration failures** with error logging

## 🎯 Expected Behavior

After completing these steps:

1. ✅ App requests notification permission on first launch
2. ✅ FCM token is generated and logged
3. ✅ Local notifications appear with sound
4. ✅ Order notifications play custom `newOrder.wav` sound
5. ✅ Push notifications from backend are received
6. ✅ Tapping notification opens the app
7. ✅ Badge count updates properly

## 🚀 Next Steps

1. Complete the manual steps above
2. Test notifications on a real device (push notifications don't work on simulator)
3. Verify FCM token is sent to your backend
4. Test receiving push notifications from your server

---

**Need Help?**

If you still have issues after following this guide:
1. Check Xcode console logs for errors
2. Verify all steps were completed
3. Try on a different iOS device
4. Check Firebase Console for any configuration issues


