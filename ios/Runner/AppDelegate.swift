import Flutter
import FirebaseCore
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBqS-h09VgMhT_UWrt0jK8bRg26x9vF-Tk")
    FirebaseApp.configure()

    // Lets flutter_local_notifications / firebase_messaging present notifications
    // while the app is in the foreground. Permission is requested from Dart.
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle (required when building with the iOS 27 SDK): plugins
  // register on the implicit engine created by the scene.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    KleanoNative.register(with: engineBridge.pluginRegistry)
  }
}

class SceneDelegate: FlutterSceneDelegate {}
