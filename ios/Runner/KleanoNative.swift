import Flutter
import UIKit

/// Native iOS pieces Flutter cannot draw itself:
///  - `kleano/liquid_glass`: Apple's real Liquid Glass (`UIGlassEffect`, iOS 26+)
///    as a platform view that Flutter content is layered on top of.
///  - `kleano/fold`: iPhone Duo fold line (`reservedRegions(kind: .division)`)
///    and hinge state (`UIHingeInteraction`), which Flutter 3.47 does not
///    report on iOS, streamed to Dart as display features.
enum KleanoNative {
  static func register(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "KleanoNative") else { return }
    let messenger = registrar.messenger()
    registrar.register(GlassViewFactory(messenger: messenger), withId: "kleano/liquid_glass")
    registrar.register(
      SimpleFactory(messenger: messenger) { GlassButtonPlatformView(frame: $0, viewId: $1, args: $2, messenger: $3) },
      withId: "kleano/glass_button")
    registrar.register(
      SimpleFactory(messenger: messenger) { TabBarPlatformView(frame: $0, viewId: $1, args: $2, messenger: $3) },
      withId: "kleano/tab_bar")
    FoldBridge.shared.attach(registrar: registrar)
    let appearance = FlutterMethodChannel(name: "kleano/appearance", binaryMessenger: messenger)
    appearance.setMethodCallHandler { call, result in
      let style: UIUserInterfaceStyle
      switch call.arguments as? String {
      case "dark": style = .dark
      case "light": style = .light
      default: style = .unspecified
      }
      for scene in UIApplication.shared.connectedScenes {
        (scene as? UIWindowScene)?.windows.forEach { $0.overrideUserInterfaceStyle = style }
      }
      result(nil)
    }
  }
}

// MARK: - Liquid Glass platform view

final class GlassViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    GlassPlatformView(
      frame: frame,
      viewId: viewId,
      args: args as? [String: Any] ?? [:],
      messenger: messenger
    )
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

final class GlassPlatformView: NSObject, FlutterPlatformView {
  private let effectView = UIVisualEffectView(effect: nil)
  private let channel: FlutterMethodChannel

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "kleano/liquid_glass/\(viewId)", binaryMessenger: messenger)
    super.init()
    effectView.frame = frame
    // Touches belong to the Flutter content drawn on top of the glass.
    effectView.isUserInteractionEnabled = false
    apply(args)
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "update", let args = call.arguments as? [String: Any] {
        self?.apply(args)
      }
      result(nil)
    }
  }

  func view() -> UIView { effectView }

  /// args: `radius` (points, negative = capsule), `tint` (ARGB int, optional),
  /// `style` ("regular" | "clear").
  private func apply(_ args: [String: Any]) {
    let radius = (args["radius"] as? NSNumber)?.doubleValue ?? 24
    let tint = (args["tint"] as? NSNumber).map { UIColor(argb: $0.uint32Value) }
    let clear = (args["style"] as? String) == "clear"

    if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: clear ? .clear : .regular)
      glass.tintColor = tint
      effectView.effect = glass
      effectView.cornerConfiguration = radius < 0
        ? .capsule()
        : .corners(radius: .fixed(radius))
    } else {
      effectView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
      effectView.contentView.backgroundColor = tint?.withAlphaComponent(0.25)
      effectView.layer.cornerCurve = .continuous
      effectView.layer.cornerRadius = radius < 0 ? effectView.bounds.height / 2 : radius
      effectView.clipsToBounds = true
    }
  }
}

/// Generic factory for the native controls below.
final class SimpleFactory: NSObject, FlutterPlatformViewFactory {
  typealias Builder = (CGRect, Int64, [String: Any], FlutterBinaryMessenger) -> FlutterPlatformView
  private let messenger: FlutterBinaryMessenger
  private let build: Builder

  init(messenger: FlutterBinaryMessenger, build: @escaping Builder) {
    self.messenger = messenger
    self.build = build
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    build(frame, viewId, args as? [String: Any] ?? [:], messenger)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

// MARK: - Real glass buttons (UIButton.Configuration.glass / prominentGlass)

/// Apple's own glass button: native touch feedback (the interactive "liquid"
/// press), SF font and SF Symbols. Taps are reported to Flutter.
/// args: `title`, `symbol` (SF Symbol), `style` ("glass" | "prominent" |
/// "clear"), `tint` / `foreground` (ARGB), `fontSize`, `iconSize`, `enabled`.
final class GlassButtonPlatformView: NSObject, FlutterPlatformView {
  private let button = UIButton(type: .system)
  private let channel: FlutterMethodChannel

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "kleano/glass_button/\(viewId)", binaryMessenger: messenger)
    super.init()
    button.frame = frame
    button.addAction(
      UIAction { [weak self] _ in self?.channel.invokeMethod("pressed", arguments: nil) },
      for: .primaryActionTriggered)
    apply(args)
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "update", let args = call.arguments as? [String: Any] {
        self?.apply(args)
      }
      result(nil)
    }
  }

  func view() -> UIView { button }

  private func apply(_ args: [String: Any]) {
    let style = args["style"] as? String ?? "glass"
    var config: UIButton.Configuration
    if #available(iOS 26.0, *) {
      switch style {
      case "prominent": config = .prominentGlass()
      case "clear": config = .clearGlass()
      default: config = .glass()
      }
    } else {
      config = style == "prominent" ? .filled() : .tinted()
    }
    config.cornerStyle = .capsule

    let fontSize = (args["fontSize"] as? NSNumber).map { CGFloat($0.doubleValue) } ?? 17
    if let title = args["title"] as? String, !title.isEmpty {
      var text = AttributedString(title)
      text.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
      config.attributedTitle = text
    }
    if let symbol = args["symbol"] as? String {
      let size = (args["iconSize"] as? NSNumber).map { CGFloat($0.doubleValue) } ?? 17
      config.image = UIImage(
        systemName: symbol,
        withConfiguration: UIImage.SymbolConfiguration(pointSize: size, weight: .semibold))
      config.imagePadding = 6
    }
    if let fg = args["foreground"] as? NSNumber {
      let color = UIColor(argb: fg.uint32Value)
      config.baseForegroundColor = color
      // Glass buttons draw SF Symbols in the button's tint, not the base
      // foreground: without this a white back chevron renders black.
      config.imageColorTransformer = UIConfigurationColorTransformer { _ in color }
      // Glass can still recolour a template symbol to suit what is behind it,
      // which turned the white bell black: fix the colour in the image itself.
      config.image = config.image?.withTintColor(color, renderingMode: .alwaysOriginal)
      // Plain glass also reads the symbol colour from tintColor (prominent
      // glass uses tintColor for its fill, set below).
      if style != "prominent" { button.tintColor = color }
    }
    if let tint = args["tint"] as? NSNumber {
      // Prominent glass takes its colour from the tint (brand purple).
      button.tintColor = UIColor(argb: tint.uint32Value)
    }
    // Directional SF Symbols (chevron.backward) read the layout direction from
    // the trait collection, not semanticContentAttribute.
    let rtl = args["rtl"] as? Bool ?? false
    button.semanticContentAttribute = rtl ? .forceRightToLeft : .forceLeftToRight
    if #available(iOS 17.0, *) {
      button.traitOverrides.layoutDirection = rtl ? .rightToLeft : .leftToRight
    }
    button.configuration = config
    button.accessibilityLabel = args["label"] as? String
    button.isEnabled = args["enabled"] as? Bool ?? true
  }
}

// MARK: - Real UITabBar

/// Apple's tab bar. Items come from Flutter (title + template PNG at 3x).
/// args: `items` [{title, icon}], `selected`, `tint`, `rtl`.
final class TabBarPlatformView: NSObject, FlutterPlatformView, UITabBarDelegate {
  private let tabBar = UITabBar()
  private let channel: FlutterMethodChannel

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "kleano/tab_bar/\(viewId)", binaryMessenger: messenger)
    super.init()
    tabBar.frame = frame
    tabBar.delegate = self
    apply(args)
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "update", let args = call.arguments as? [String: Any] {
        self?.apply(args)
      }
      result(nil)
    }
  }

  func view() -> UIView { tabBar }

  private func apply(_ args: [String: Any]) {
    let specs = args["items"] as? [[String: Any]] ?? []
    let items = specs.enumerated().map { index, spec -> UITabBarItem in
      let data = (spec["icon"] as? FlutterStandardTypedData)?.data
      let image = data.flatMap { UIImage(data: $0, scale: 3) }?.withRenderingMode(.alwaysTemplate)
      return UITabBarItem(title: spec["title"] as? String, image: image, tag: index)
    }
    if tabBar.items?.count != items.count
      || zip(tabBar.items ?? [], items).contains(where: { $0.title != $1.title })
    {
      tabBar.setItems(items, animated: false)
    }
    let selected = (args["selected"] as? NSNumber)?.intValue ?? 0
    if let current = tabBar.items, selected < current.count {
      tabBar.selectedItem = current[selected]
    }
    if let tint = args["tint"] as? NSNumber {
      tabBar.tintColor = UIColor(argb: tint.uint32Value)
    }
    tabBar.semanticContentAttribute =
      (args["rtl"] as? Bool ?? false) ? .forceRightToLeft : .forceLeftToRight
  }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    channel.invokeMethod("select", arguments: item.tag)
  }
}

private extension UIColor {
  convenience init(argb: UInt32) {
    self.init(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255)
  }
}

// MARK: - iPhone Duo fold / hinge

final class FoldBridge: NSObject, FlutterStreamHandler {
  static let shared = FoldBridge()

  private weak var registrar: FlutterPluginRegistrar?
  private var sink: FlutterEventSink?
  private var observer: FoldObserverView?
  private var hingeStatus = 0
  private var hingeAngle = 0.0
  private var lastPayload: NSDictionary?

  func attach(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    FlutterEventChannel(name: "kleano/fold", binaryMessenger: registrar.messenger())
      .setStreamHandler(self)
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    lastPayload = nil
    installObserver()
    send()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  private func installObserver() {
    guard observer == nil else { return }
    guard let host = registrar?.viewController?.view else {
      // The scene's Flutter view may not exist yet; try again shortly.
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        self?.installObserver()
      }
      return
    }
    let view = FoldObserverView(frame: host.bounds)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.isUserInteractionEnabled = false
    view.backgroundColor = .clear
    view.onLayout = { [weak self] in self?.send() }
    host.addSubview(view)

    if #available(iOS 27.1, *) {
      view.addInteraction(UIHingeInteraction { [weak self] _, update in
        guard let self else { return }
        if let hinge = update.hinge {
          self.hingeStatus = hinge.status.rawValue
          self.hingeAngle = Double(hinge.angle)
        } else {
          self.hingeStatus = 0
        }
        self.send()
      })
    }
    observer = view
    send()
  }

  private func send() {
    guard let sink, let view = observer else { return }
    var regions: [[String: Any]] = []
    if #available(iOS 27.1, *) {
      for (kind, name) in [(UIView.ReservedRegion.Kind.division, "division"),
                           (.occlusion, "occlusion")] {
        for region in view.reservedRegions(kind: kind) where region.isActive {
          regions.append([
            "kind": name,
            "x": region.frame.origin.x, "y": region.frame.origin.y,
            "width": region.frame.width, "height": region.frame.height,
          ])
        }
      }
    }
    let payload: NSDictionary = [
      "hinge": hingeStatus,
      "angle": hingeAngle,
      "regions": regions,
    ]
    // layoutSubviews fires often; only send real changes.
    if payload == lastPayload { return }
    lastPayload = payload
    sink(payload)
  }
}

/// Invisible full-size view: its layout pass tells us when the window
/// changes (fold, unfold, rotate) so reserved regions can be re-read.
final class FoldObserverView: UIView {
  var onLayout: (() -> Void)?

  override func layoutSubviews() {
    super.layoutSubviews()
    onLayout?()
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { nil }
}
