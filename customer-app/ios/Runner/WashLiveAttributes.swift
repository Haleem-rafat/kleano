import ActivityKit
import Foundation

/// Shared by the app (starts and updates) and the widget extension (draws).
@available(iOS 16.1, *)
struct WashLiveAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    /// Translated by the app, which knows the chosen language.
    var stage: String
    /// -1 accepted, 0 on the way, 1 arrived, 2 washing, 3 completed.
    var step: Int
  }

  var orderId: String
  var vehicle: String
  var address: String
  var stageLabels: [String]
  var rtl: Bool
}
