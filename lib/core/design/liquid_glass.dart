import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Liquid Glass design system following Apple's HIG (iOS 26/27):
///
///  * Glass is the *controls layer* (tab bar, toolbar buttons, floating
///    controls) floating above content; content itself stays opaque.
///  * On iOS the material is Apple's real `UIGlassEffect`, rendered natively
///    (platform view `kleano/liquid_glass`) underneath the Flutter content, so
///    refraction, adaptive tint, the iOS 27 transparency setting and Reduce
///    Transparency are handled by the system.
///  * On Android (and in tests) a Flutter-drawn approximation is used.
///  * Brand colour goes on the tint of controls, not on bar backgrounds.
class GlassTokens {
  GlassTokens._();

  static const double blurSigma = 22;
  static const double radius = 26;
  static const double sheetRadius = 34;
  static const double dialogRadius = 30;

  static const Color tintLight = Color(0xB8FFFFFF);
  static const Color tintLightLow = Color(0x8CFFFFFF);
  static const Color opaqueSurface = Color(0xFFF7F7FA);
  static const Color sheetSurface = Color(0xF5FFFFFF);
  static const Color barrier = Color(0x40000000);

  static ShapeBorder shape(double radius) =>
      RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radius));

  /// Opaque when the platform asks for contrast over translucency.
  static bool reduceTransparency(BuildContext context) =>
      MediaQuery.highContrastOf(context);

  /// Use Apple's real `UITabBar` for tab bars on iOS.
  static bool nativeTabBar = true;

  /// Whether Apple's native glass is used (iOS app builds).
  static bool get useNative =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}

/// Glass variants from Apple's API (`UIGlassEffect.Style`).
enum GlassStyle { regular, clear }

/// A piece of Liquid Glass. Wrap any control to put it on the material.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.radius = GlassTokens.radius,
    this.capsule = false,
    this.padding,
    this.tint,
    this.style = GlassStyle.regular,
    this.blurSigma = GlassTokens.blurSigma,
    this.shadow = true,
  });

  final Widget child;
  final double radius;

  /// Fully rounded ends (Apple's capsule shape); ignores [radius].
  final bool capsule;
  final EdgeInsetsGeometry? padding;

  /// Tinted glass (Apple: `glass.tintColor`), e.g. the brand colour for a
  /// prominent control. Null = clear, untinted glass.
  final Color? tint;
  final GlassStyle style;
  final double blurSigma;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final Widget content = padding == null
        ? child
        : Padding(padding: padding!, child: child);

    if (GlassTokens.useNative) {
      return Stack(
        children: <Widget>[
          Positioned.fill(
            child: NativeGlassView(
              radius: capsule ? -1 : radius,
              tint: tint,
              style: style,
            ),
          ),
          content,
        ],
      );
    }
    return _FlutterGlass(
      radius: radius,
      capsule: capsule,
      tint: tint,
      blurSigma: blurSigma,
      shadow: shadow,
      child: content,
    );
  }
}

/// Apple's `UIGlassEffect` hosted as an iOS platform view.
class NativeGlassView extends StatefulWidget {
  const NativeGlassView({
    super.key,
    this.radius = GlassTokens.radius,
    this.tint,
    this.style = GlassStyle.regular,
  });

  /// Corner radius in points; negative means capsule.
  final double radius;
  final Color? tint;
  final GlassStyle style;

  @override
  State<NativeGlassView> createState() => _NativeGlassViewState();
}

class _NativeGlassViewState extends State<NativeGlassView> {
  MethodChannel? _channel;

  Map<String, Object?> get _params => <String, Object?>{
    'radius': widget.radius,
    'tint': widget.tint?.toARGB32(),
    'style': widget.style.name,
  };

  @override
  void didUpdateWidget(NativeGlassView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.radius != widget.radius ||
        oldWidget.tint != widget.tint ||
        oldWidget.style != widget.style) {
      _channel?.invokeMethod<void>('update', _params);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: 'kleano/liquid_glass',
      creationParams: _params,
      creationParamsCodec: const StandardMessageCodec(),
      // The glass is decoration: taps go to the Flutter content above it.
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
      onPlatformViewCreated: (int id) =>
          _channel = MethodChannel('kleano/liquid_glass/$id'),
    );
  }
}

/// Flutter-drawn approximation for Android: blur, tint, specular rim and
/// continuous corners. Opaque when transparency is reduced.
class _FlutterGlass extends StatelessWidget {
  const _FlutterGlass({
    required this.child,
    required this.radius,
    required this.capsule,
    required this.tint,
    required this.blurSigma,
    required this.shadow,
  });

  final Widget child;
  final double radius;
  final bool capsule;
  final Color? tint;
  final double blurSigma;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final bool opaque = GlassTokens.reduceTransparency(context);
    final Color base = tint == null
        ? GlassTokens.tintLight
        : Color.alphaBlend(
            tint!.withValues(alpha: tint!.a * 0.85),
            GlassTokens.tintLightLow,
          );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double r = capsule && c.hasBoundedHeight
            ? c.maxHeight / 2
            : radius;
        final BorderRadius borderRadius = BorderRadius.circular(
          capsule ? 999 : r,
        );
        final ShapeBorder shape = capsule
            ? const StadiumBorder()
            : RoundedSuperellipseBorder(borderRadius: borderRadius);

        Widget surface = DecoratedBox(
          decoration: ShapeDecoration(
            shape: shape,
            color: opaque
                ? Color.alphaBlend(base, GlassTokens.opaqueSurface)
                : null,
            gradient: opaque
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      base,
                      base.withValues(alpha: base.a * 0.72),
                    ],
                  ),
          ),
          child: CustomPaint(
            foregroundPainter: _SpecularEdgePainter(borderRadius),
            child: child,
          ),
        );

        if (!opaque) {
          surface = ClipRSuperellipse(
            borderRadius: borderRadius,
            child: BackdropFilter.grouped(
              filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: surface,
            ),
          );
        }
        if (!shadow) return surface;
        return DecoratedBox(
          decoration: ShapeDecoration(
            shape: shape,
            shadows: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: surface,
        );
      },
    );
  }
}

/// Thin light-catching rim: bright top-left, fading, softer bottom-right.
class _SpecularEdgePainter extends CustomPainter {
  _SpecularEdgePainter(this.borderRadius);

  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final BorderRadius clamped = BorderRadius.circular(
      borderRadius.topLeft.x.clamp(0, size.shortestSide / 2).toDouble(),
    );
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xE6FFFFFF),
          Color(0x33FFFFFF),
          Color(0x14FFFFFF),
          Color(0x80FFFFFF),
        ],
        stops: <double>[0, 0.35, 0.7, 1],
      ).createShader(rect);
    canvas.drawRSuperellipse(clamped.toRSuperellipse(rect.deflate(0.5)), paint);
  }

  @override
  bool shouldRepaint(_SpecularEdgePainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius;
}

/// Apple's real glass button (`UIButton.Configuration.glass()` /
/// `.prominentGlass()`) on iOS: native press feedback, SF font, SF Symbols.
/// Other platforms get [fallback].
enum GlassButtonStyle { glass, prominent, clear }

class NativeGlassButton extends StatefulWidget {
  const NativeGlassButton({
    super.key,
    required this.onPressed,
    required this.fallback,
    this.title,
    this.sfSymbol,
    this.style = GlassButtonStyle.glass,
    this.tint,
    this.foreground,
    this.fontSize = 17,
    this.iconSize = 17,
  });

  final VoidCallback? onPressed;
  final Widget fallback;
  final String? title;
  final String? sfSymbol;
  final GlassButtonStyle style;
  final Color? tint;
  final Color? foreground;
  final double fontSize;
  final double iconSize;

  @override
  State<NativeGlassButton> createState() => _NativeGlassButtonState();
}

class _NativeGlassButtonState extends State<NativeGlassButton> {
  MethodChannel? _channel;

  Map<String, Object?> get _params => <String, Object?>{
    'title': widget.title,
    'symbol': widget.sfSymbol,
    'style': widget.style.name,
    'tint': widget.tint?.toARGB32(),
    'foreground': widget.foreground?.toARGB32(),
    'fontSize': widget.fontSize,
    'iconSize': widget.iconSize,
    'enabled': widget.onPressed != null,
    // The app can be Arabic on an English iPhone: directional SF Symbols
    // follow this, not the system language.
    'rtl': Directionality.of(context) == TextDirection.rtl,
  };

  @override
  void didUpdateWidget(NativeGlassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _channel?.invokeMethod<void>('update', _params);
  }

  @override
  Widget build(BuildContext context) {
    if (!GlassTokens.useNative) return widget.fallback;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // An unbounded platform view gets an infinite frame and iOS kills the
        // app (CALayer NaN). Give the caller a visible error instead.
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          assert(false, 'NativeGlassButton needs a bounded size: $constraints');
          return widget.fallback;
        }
        return _native();
      },
    );
  }

  Widget _native() {
    return Semantics(
      button: true,
      label: widget.title,
      child: UiKitView(
        viewType: 'kleano/glass_button',
        creationParams: _params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          _channel = MethodChannel('kleano/glass_button/$id')
            ..setMethodCallHandler((MethodCall call) async {
              if (call.method == 'pressed') widget.onPressed?.call();
            });
        },
      ),
    );
  }
}

/// Circular glass button, Apple's toolbar style (back, close, map controls).
/// With [sfSymbol] it is Apple's real glass button on iOS.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.sfSymbol,
    this.color,
    this.tint,
    this.size = 44,
    this.iconSize = 20,
    this.tooltip,
  });

  final IconData icon;

  /// SF Symbol name used on iOS (e.g. `chevron.backward`, `xmark`, `plus`).
  final String? sfSymbol;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? tint;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = color ?? Theme.of(context).colorScheme.onSurface;
    if (GlassTokens.useNative && sfSymbol != null) {
      return SizedBox.square(
        dimension: size,
        child: NativeGlassButton(
          onPressed: onPressed,
          sfSymbol: sfSymbol,
          foreground: iconColor,
          tint: tint,
          iconSize: iconSize,
          fallback: const SizedBox.shrink(),
        ),
      );
    }
    final Widget button = Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onPressed!();
              },
        child: SizedBox.square(
          dimension: size,
          child: LiquidGlass(
            capsule: true,
            tint: tint,
            child: Center(
              child: Icon(icon, size: iconSize, color: iconColor),
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// Apple-style back button: a chevron on a glass circle. Mirrors in RTL.
class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key, this.onPressed, this.color});

  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: Center(
        child: GlassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          // Mirrors automatically in right-to-left languages.
          sfSymbol: 'chevron.backward',
          color: color,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: onPressed ?? () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}

/// One destination of a [GlassTabBar].
class GlassTabItem {
  const GlassTabItem({
    required this.label,
    required this.iconBuilder,
    this.svgAsset,
  });

  final String label;

  /// SVG icon asset; lets iOS show the item in Apple's real `UITabBar`.
  final String? svgAsset;

  /// Builds the icon for the given state (so SVG assets can be tinted).
  final Widget Function(bool selected, Color color) iconBuilder;
}

/// Floating capsule tab bar (iOS 26/27) with a selection lens. Width-capped
/// and centred on wide screens; on iPhone Duo it stays inside one pane so it
/// never straddles the fold.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor = const Color(0xFF6E6E73),
    this.labelStyle,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? activeColor;
  final Color inactiveColor;
  final TextStyle? labelStyle;

  static const double _height = 62;
  static const double _maxWidth = 560;

  @override
  Widget build(BuildContext context) {
    final Color active = activeColor ?? Theme.of(context).colorScheme.primary;
    if (GlassTokens.useNative &&
        GlassTokens.nativeTabBar &&
        items.every((GlassTabItem i) => i.svgAsset != null)) {
      return SafeArea(
        top: false,
        left: false,
        right: false,
        child: FoldPane(
          child: SizedBox(
            height: 62,
            child: _NativeTabBar(
              items: items,
              currentIndex: currentIndex,
              onTap: onTap,
              tint: active,
            ),
          ),
        ),
      );
    }
    final TextStyle baseLabel = (labelStyle ?? const TextStyle()).copyWith(
      fontSize: 10.5,
      height: 1.1,
    );
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    final Widget bar = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: _height,
          child: LiquidGlass(
            capsule: true,
            padding: const EdgeInsets.all(4),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                final double itemWidth = c.maxWidth / items.length;
                final bool rtl =
                    Directionality.of(context) == TextDirection.rtl;
                final int visual = rtl
                    ? items.length - 1 - currentIndex
                    : currentIndex;
                return Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      left: visual * itemWidth,
                      width: itemWidth,
                      top: 0,
                      bottom: 0,
                      child: _Lens(color: active),
                    ),
                    Row(
                      children: <Widget>[
                        for (int i = 0; i < items.length; i++)
                          Expanded(
                            child: _TabButton(
                              item: items[i],
                              selected: i == currentIndex,
                              color: i == currentIndex ? active : inactiveColor,
                              labelStyle: baseLabel,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    // Only the bottom inset applies: side insets on iPhone Duo's outer
    // screen come from the camera island at the top, far from this bar.
    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: FoldPane(child: Center(heightFactor: 1, child: bar)),
    );
  }
}

class _NativeTabBar extends StatefulWidget {
  const _NativeTabBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.tint,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color tint;

  @override
  State<_NativeTabBar> createState() => _NativeTabBarState();
}

class _NativeTabBarState extends State<_NativeTabBar> {
  static final Map<String, Uint8List> _iconCache = <String, Uint8List>{};
  List<Uint8List>? _icons;
  MethodChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  /// UIKit needs bitmaps: render each SVG once as a 25pt template at 3x.
  Future<void> _loadIcons() async {
    final List<Uint8List> icons = <Uint8List>[];
    for (final GlassTabItem item in widget.items) {
      final String asset = item.svgAsset!;
      icons.add(_iconCache[asset] ??= await _renderSvg(asset));
    }
    if (mounted) setState(() => _icons = icons);
  }

  static Future<Uint8List> _renderSvg(String asset) async {
    const double logical = 25, scale = 3;
    final PictureInfo info = await vg.loadPicture(SvgAssetLoader(asset), null);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final double factor =
        logical *
        scale /
        (info.size.longestSide == 0 ? 1 : info.size.longestSide);
    canvas.scale(factor);
    canvas.drawPicture(info.picture);
    info.picture.dispose();
    final int px = (logical * scale).round();
    final ui.Image image = await recorder.endRecording().toImage(px, px);
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  Map<String, Object?> _params(BuildContext context) => <String, Object?>{
    'items': <Map<String, Object?>>[
      for (int i = 0; i < widget.items.length; i++)
        <String, Object?>{'title': widget.items[i].label, 'icon': _icons![i]},
    ],
    'selected': widget.currentIndex,
    'tint': widget.tint.toARGB32(),
    'rtl': Directionality.of(context) == TextDirection.rtl,
  };

  @override
  void didUpdateWidget(_NativeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_icons != null)
      _channel?.invokeMethod<void>('update', _params(context));
  }

  @override
  Widget build(BuildContext context) {
    if (_icons == null) return const SizedBox.shrink();
    return UiKitView(
      viewType: 'kleano/tab_bar',
      creationParams: _params(context),
      creationParamsCodec: const StandardMessageCodec(),
      // UITabBar tracks its own touches: without claiming them at once,
      // Flutter delays them until its gesture arena settles and the tab
      // switch is lost.
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      },
      onPlatformViewCreated: (int id) {
        _channel = MethodChannel('kleano/tab_bar/$id')
          ..setMethodCallHandler((MethodCall call) async {
            if (call.method == 'select') widget.onTap(call.arguments as int);
          });
      },
    );
  }
}

class _Lens extends StatelessWidget {
  const _Lens({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // Apple's selected-tab pill: a slightly denser, faintly tinted capsule.
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: Color.alphaBlend(
          color.withValues(alpha: 0.10),
          const Color(0x66FFFFFF),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.color,
    required this.labelStyle,
    required this.onTap,
  });

  final GlassTabItem item;
  final bool selected;
  final Color color;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.0 : 0.96,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox.square(
                dimension: 24,
                child: item.iconBuilder(selected, color),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: MediaQuery.textScalerOf(
                  context,
                ).clamp(maxScaleFactor: 1.2),
                style: labelStyle.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// iOS 26/27 navigation bar: no coloured background. Content scrolls under a
/// soft scroll-edge fade; the back button is a glass circle.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.tint,
    this.foregroundColor,
    this.titleSpacing,
    this.leadingWidth,
    this.systemOverlayStyle,
    this.toolbarHeight = kToolbarHeight,
    this.bottom,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;

  /// Kept for API compatibility. Apple's HIG avoids tinted bar backgrounds,
  /// so the tint only colours the title/back button.
  final Color? tint;
  final Color? foregroundColor;
  final double? titleSpacing;
  final double? leadingWidth;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final double toolbarHeight;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final Color background = Theme.of(context).scaffoldBackgroundColor;
    final Color fg = foregroundColor == Colors.white || foregroundColor == null
        ? const Color(0xFF1C1C1E)
        : foregroundColor!;
    final bool canPop = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    return AppBar(
      title: title == null
          ? null
          : DefaultTextStyle.merge(
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
              child: IconTheme.merge(
                data: IconThemeData(color: fg),
                child: title!,
              ),
            ),
      leading:
          leading ??
          (automaticallyImplyLeading && canPop
              ? GlassBackButton(color: tint)
              : null),
      leadingWidth: leading == null && automaticallyImplyLeading && canPop
          ? 60
          : leadingWidth,
      automaticallyImplyLeading: false,
      actions: actions,
      centerTitle: centerTitle ?? true,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.dark,
      bottom: bottom,
      foregroundColor: fg,
      iconTheme: IconThemeData(color: tint ?? fg),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      // Scroll-edge effect: content fades out under the bar.
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              background,
              background.withValues(alpha: 0.92),
              background.withValues(alpha: 0),
            ],
            stops: const <double>[0, 0.75, 1],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// iPhone Duo (foldable) support
// ---------------------------------------------------------------------------

/// Feeds the iPhone Duo fold line and hinge posture (from the native
/// `kleano/fold` bridge) into [MediaQueryData.displayFeatures], so Flutter's
/// own fold handling (dialogs, menus, sheets via `DisplayFeatureSubScreen`)
/// and [FoldPane] work on iOS like they do on Android foldables.
class FoldScope extends StatefulWidget {
  const FoldScope({super.key, required this.child});

  final Widget child;

  static const EventChannel _channel = EventChannel('kleano/fold');

  @override
  State<FoldScope> createState() => _FoldScopeState();
}

class _FoldScopeState extends State<FoldScope> {
  StreamSubscription<dynamic>? _sub;
  List<ui.DisplayFeature> _features = const <ui.DisplayFeature>[];

  @override
  void initState() {
    super.initState();
    if (GlassTokens.useNative) {
      _sub = FoldScope._channel.receiveBroadcastStream().listen(
        _onEvent,
        onError: (Object _) {},
      );
    }
  }

  void _onEvent(dynamic event) {
    if (event is! Map) return;
    if (kDebugMode) debugPrint("kleano/fold: $event");
    final int hinge = (event['hinge'] as num?)?.toInt() ?? 0;
    final ui.DisplayFeatureState posture = switch (hinge) {
      2 => ui.DisplayFeatureState.postureHalfOpened,
      3 => ui.DisplayFeatureState.postureFlat,
      _ => ui.DisplayFeatureState.unknown,
    };
    final List<ui.DisplayFeature> features = <ui.DisplayFeature>[
      // Only the fold line splits the layout; camera occlusions are handled
      // by safe-area padding.
      for (final dynamic r
          in (event['regions'] as List<dynamic>? ?? <dynamic>[]))
        if (r is Map && r['kind'] == 'division')
          ui.DisplayFeature(
            bounds: Rect.fromLTWH(
              (r['x'] as num).toDouble(),
              (r['y'] as num).toDouble(),
              (r['width'] as num).toDouble(),
              (r['height'] as num).toDouble(),
            ),
            type: ui.DisplayFeatureType.hinge,
            state: posture,
          ),
    ];
    if (mounted) setState(() => _features = features);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_features.isEmpty) return widget.child;
    final MediaQueryData mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        displayFeatures: <ui.DisplayFeature>[
          ...mq.displayFeatures,
          ..._features,
        ],
      ),
      child: widget.child,
    );
  }
}

/// Keeps a full-width control inside one pane when a fold/hinge splits the
/// screen (iPhone Duo unfolded, Android foldables). No-op otherwise.
class FoldPane extends StatelessWidget {
  const FoldPane({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool hasFold = MediaQuery.displayFeaturesOf(context).any(
      (ui.DisplayFeature f) =>
          f.type != ui.DisplayFeatureType.cutout &&
          f.bounds.height > f.bounds.width,
    );
    if (!hasFold) return child;
    // Same pane-picking rules Flutter uses for dialogs (leading pane first).
    return DisplayFeatureSubScreen(child: child);
  }
}

// ---------------------------------------------------------------------------
// iPhone Duo / resizable windows (Apple "app-resizability" + "Design for
// iPhone Duo"): content never sits under vertical system bars, and regular
// width shows the tab bar as a sidebar.
// ---------------------------------------------------------------------------

/// Width at which a window counts as regular width (inner display, iPad,
/// landscape) instead of compact (phones, iPhone Duo outer display).
const double kRegularWidth = 600;

bool isRegularWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kRegularWidth;

/// Insets every page from a vertical system bar.
///
/// On iPhone Duo's outer display the status bar is a vertical strip on the
/// trailing edge; iOS reports it as a horizontal safe-area inset that lasts
/// for the whole configuration. Apple: content must be offset from it. On a
/// compact window with a tall side inset, pages are inset here once (and the
/// inset is removed from MediaQuery so nothing applies it twice); phones in
/// landscape (regular width) keep their normal full-bleed behaviour.
class SystemBarInset extends StatelessWidget {
  const SystemBarInset({super.key, required this.child, this.background});

  final Widget child;
  final Color? background;

  /// Narrower insets are corners / notches, not a vertical system bar.
  static const double minBarInset = 44;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final EdgeInsets p = mq.padding;
    final bool verticalBar =
        mq.size.width < kRegularWidth &&
        (p.left >= minBarInset || p.right >= minBarInset);
    if (!verticalBar) return child;

    return ColoredBox(
      color: background ?? Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(left: p.left, right: p.right),
        child: MediaQuery(
          data: mq
              .removePadding(removeLeft: true, removeRight: true)
              .copyWith(
                viewPadding: mq.viewPadding.copyWith(left: 0, right: 0),
                size: Size(mq.size.width - p.left - p.right, mq.size.height),
              ),
          child: child,
        ),
      ),
    );
  }
}

/// Apple's "tab bar as a sidebar" for regular-width windows (iPhone Duo
/// unfolded, iPad, landscape): a floating Liquid Glass panel on the leading
/// edge, kept inside one pane of the fold.
class GlassSidebar extends StatelessWidget {
  const GlassSidebar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.title,
    this.activeColor,
    this.inactiveColor = const Color(0xFF3A3A3C),
    this.labelStyle,
    this.width = 248,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? title;
  final Color? activeColor;
  final Color inactiveColor;
  final TextStyle? labelStyle;
  final double width;

  @override
  Widget build(BuildContext context) {
    final Color active = activeColor ?? Theme.of(context).colorScheme.primary;
    final TextStyle base = (labelStyle ?? const TextStyle()).copyWith(
      fontSize: 16,
      height: 1.2,
    );
    return SafeArea(
      right: false,
      minimum: const EdgeInsetsDirectional.only(
        start: 10,
        top: 10,
        bottom: 10,
      ).resolve(Directionality.of(context)),
      child: SizedBox(
        width: width,
        child: LiquidGlass(
          radius: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (title != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 10, 14),
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                    child: title!,
                  ),
                ),
              for (int i = 0; i < items.length; i++)
                _SidebarRow(
                  item: items[i],
                  selected: i == currentIndex,
                  color: i == currentIndex ? active : inactiveColor,
                  labelStyle: base,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.item,
    required this.selected,
    required this.color,
    required this.labelStyle,
    required this.onTap,
  });

  final GlassTabItem item;
  final bool selected;
  final Color color;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: selected
                ? color.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Row(
            children: <Widget>[
              SizedBox.square(
                dimension: 24,
                child: item.iconBuilder(selected, color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Applies the Liquid Glass look to stock Material components so every sheet,
/// dialog, snackbar, button and page transition in the app matches.
class LiquidGlassTheme {
  LiquidGlassTheme._();

  static ThemeData apply(ThemeData base, {required Color primary}) {
    const RoundedSuperellipseBorder sheetShape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(GlassTokens.sheetRadius),
      ),
    );
    final RoundedSuperellipseBorder dialogShape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(GlassTokens.dialogRadius),
    );
    const ButtonStyle capsule = ButtonStyle(
      shape: WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
      animationDuration: Duration(milliseconds: 180),
    );

    return base.copyWith(
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          // Android 16 predictive back (swipe preview of the previous page).
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: GlassTokens.sheetSurface,
        modalBackgroundColor: GlassTokens.sheetSurface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: GlassTokens.barrier,
        shape: sheetShape,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        modalElevation: 0,
        // Sheets never stretch edge-to-edge on unfolded/large screens.
        constraints: const BoxConstraints(maxWidth: 640),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: GlassTokens.sheetSurface,
        surfaceTintColor: Colors.transparent,
        shape: dialogShape,
        elevation: 0,
        barrierColor: GlassTokens.barrier,
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xE6202024),
        shape: const StadiumBorder(),
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: base.cardTheme.copyWith(
        surfaceTintColor: Colors.transparent,
        shape: GlassTokens.shape(20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: capsule.merge(base.elevatedButtonTheme.style),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: capsule.merge(base.filledButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: capsule.merge(base.outlinedButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: capsule.merge(base.textButtonTheme.style),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        shape: const StadiumBorder(),
        elevation: 2,
        highlightElevation: 4,
      ),
      switchTheme: base.switchTheme.copyWith(
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),
      progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
        color: primary,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(primaryColor: primary),
    );
  }

  /// Keeps text readable but layouts intact at extreme accessibility sizes.
  static Widget clampTextScale(BuildContext context, Widget child) {
    final MediaQueryData mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.35,
        ),
      ),
      child: child,
    );
  }
}
