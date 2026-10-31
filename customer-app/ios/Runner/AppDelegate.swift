import UIKit
import Flutter
import FirebaseCore
import GoogleMaps


@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    #if dev
    GMSServices.provideAPIKey("AIzaSyDl8t-bqMb-Rc0QlaJyGg9opcYpN3fyzOk")
    #else
    // pro, and the un-flavored Runner configs (which define neither flag).
    GMSServices.provideAPIKey("AIzaSyD7eeF9ETvHwPlih3u5Jo5FWhUmfjf4k2s")
    #endif
    
    // Foreground presentation for local/remote notifications. Permission is
    // requested from Dart so the prompt appears in context.
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle (required on iOS 27+): plugins register on the implicit engine.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    KleanoNative.register(with: engineBridge.pluginRegistry)
  }
}

class SceneDelegate: FlutterSceneDelegate {

}
