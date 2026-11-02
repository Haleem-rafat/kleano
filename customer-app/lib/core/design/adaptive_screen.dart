import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ScreenUtil set-up that works on every screen shape: phones (portrait and
/// landscape), iPhone Duo folded (outer screen) and unfolded (inner screen),
/// Android foldables and tablets.
///
/// The UI was designed at 375x812.
///  * Compact width (< 600pt: phones, Duo outer screen, split view): the
///    original design scaling is kept (`.w` follows width, `.h` follows
///    height), so `1.sw` is still the full width. Text uses the smaller of
///    the two scales, clamped, so it fits short screens and stays readable.
///  * Wide (>= 600pt: Duo inner screen, landscape, tablets): one uniform scale
///    from the shortest side, clamped, so nothing stretches. Full-width
///    sizes must use `1.sw` / `1.sh` (never `1.sw` / `1.sh`).
///
/// It rebuilds on every metrics change (rotation, fold/unfold, split view).
class AdaptiveScreenUtil extends StatelessWidget {
  const AdaptiveScreenUtil({super.key, required this.builder});

  static const Size designSize = Size(375, 812);
  static const double minScale = 0.85;
  static const double maxScale = 1.2;
  static const double wideBreakpoint = 600;

  final WidgetBuilder builder;

  static bool isWide(Size size) => size.width >= wideBreakpoint;

  /// Uniform scale used on wide screens.
  static double scaleFor(Size size) =>
      (size.shortestSide / designSize.width).clamp(minScale, maxScale);

  static double _fontSize(num fontSize, ScreenUtil util) =>
      fontSize *
      (util.scaleWidth < util.scaleHeight ? util.scaleWidth : util.scaleHeight)
          .clamp(0.9, maxScale);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    if (size.isEmpty) return const SizedBox.shrink();

    final double scale = scaleFor(size);
    return ScreenUtilInit(
      designSize: isWide(size)
          ? Size(size.width / scale, size.height / scale)
          : designSize,
      fontSizeResolver: _fontSize,
      builder: (BuildContext context, _) => builder(context),
    );
  }
}

/// Window size classes used to adapt layouts (Material 3 breakpoints).
enum WindowSize { compact, medium, expanded }

extension WindowSizeX on BuildContext {
  WindowSize get windowSize {
    final double width = MediaQuery.sizeOf(this).width;
    if (width >= 840) return WindowSize.expanded;
    if (width >= 600) return WindowSize.medium;
    return WindowSize.compact;
  }
}

/// Centres page content with a readable max width on wide screens
/// (unfolded foldables, landscape, tablets); a no-op on phones.
class AdaptiveContent extends StatelessWidget {
  const AdaptiveContent({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// A page that uses the whole window on wide screens: maps, full-bleed photos
/// and the tab shell, which limits its own content.
abstract interface class KFullWidthPage {}

/// Gives every other page a readable width on unfolded foldables, tablets and
/// landscape, in one place. A hinge with a real gap keeps the page in one pane.
class KAdaptivePageTransitions extends PageTransitionsBuilder {
  const KAdaptivePageTransitions(this.base);

  final PageTransitionsBuilder base;

  static final Expando<bool> _fullWidth = Expando<bool>();

  static bool _isFullWidth(PageRoute<dynamic> route, BuildContext context) =>
      _fullWidth[route] ??=
          route is MaterialPageRoute<dynamic> &&
          route.builder(context) is KFullWidthPage;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => base.buildTransitions<T>(
    route,
    context,
    animation,
    secondaryAnimation,
    _isFullWidth(route, context) ? child : KReadablePage(child: child),
  );
}

/// Centres one page at a readable width; a no-op on phones.
class KReadablePage extends StatelessWidget {
  const KReadablePage({super.key, required this.child});

  static const double maxWidth = 720;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final bool gap = mq.displayFeatures.any(
      (DisplayFeature f) =>
          f.type != DisplayFeatureType.cutout &&
          f.bounds.width > 0 &&
          f.bounds.height > f.bounds.width,
    );
    if (gap) return DisplayFeatureSubScreen(child: child);
    if (mq.size.width <= maxWidth) return child;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: maxWidth,
          child: MediaQuery(
            data: mq
                .removePadding(removeLeft: true, removeRight: true)
                .copyWith(size: Size(maxWidth, mq.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
