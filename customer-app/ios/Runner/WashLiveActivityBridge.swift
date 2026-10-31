import ActivityKit
import Flutter

/// `kleano/live_activity`: the wash status on the Lock Screen and Dynamic Island.
enum WashLiveActivityBridge {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "kleano/live_activity", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard #available(iOS 16.2, *) else { return result(nil) }
      let args = call.arguments as? [String: Any] ?? [:]
      Task {
        switch call.method {
        case "show": await show(args)
        case "end": await end()
        default: break
        }
        result(nil)
      }
    }
  }

  @available(iOS 16.2, *)
  private static func show(_ args: [String: Any]) async {
    guard ActivityAuthorizationInfo().areActivitiesEnabled,
      let orderId = args["orderId"] as? String
    else {
      NSLog("Wash live activity off in Settings, or no order")
      return
    }
    let state = WashLiveAttributes.ContentState(
      stage: args["stage"] as? String ?? "", step: args["step"] as? Int ?? -1)
    let content = ActivityContent(state: state, staleDate: nil)
    let running = Activity<WashLiveAttributes>.activities
    for activity in running where activity.attributes.orderId != orderId {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    if state.step >= 3 {
      for activity in running where activity.attributes.orderId == orderId {
        // Leaves "completed" on the Lock Screen for a while, then clears.
        await activity.end(content, dismissalPolicy: .after(.now + 15 * 60))
      }
      return
    }
    if let activity = running.first(where: { $0.attributes.orderId == orderId }) {
      await activity.update(content)
      return
    }
    let attributes = WashLiveAttributes(
      orderId: orderId,
      vehicle: args["vehicle"] as? String ?? "",
      address: args["address"] as? String ?? "",
      stageLabels: args["stageLabels"] as? [String] ?? [],
      rtl: args["rtl"] as? Bool ?? false)
    do {
      _ = try Activity.request(attributes: attributes, content: content)
    } catch {
      NSLog("Wash live activity not started: \(error)")
    }
  }

  @available(iOS 16.2, *)
  private static func end() async {
    for activity in Activity<WashLiveAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
  }
}
