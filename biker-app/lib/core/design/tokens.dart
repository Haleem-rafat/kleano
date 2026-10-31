import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Kleano design tokens: the single source of colour, type, spacing, radius
/// and motion values for both apps. Documented in `docs/design-system.md`.

/// Colour palette. Purple ([brand]) is for actions and highlights only.
@immutable
class KColors {
  const KColors._({
    required this.brand,
    required this.brandLight,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.separator,
    required this.fill,
    required this.brandTint,
    required this.onBrandTint,
  });

  final Color brand;
  final Color brandLight;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;

  /// Hairlines between rows.
  final Color separator;

  /// Background of fields, segmented controls and secondary buttons.
  final Color fill;

  /// Selected segments, secondary buttons, chips. Solid, so it never picks up
  /// a tint from the surface behind it.
  final Color brandTint;
  final Color onBrandTint;

  static const KColors light = KColors._(
    brand: Color(0xFF543063),
    brandLight: Color(0xFF8E5BA6),
    background: Color(0xFFF2F2F7),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF6E6E73),
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9500),
    error: Color(0xFFFF3B30),
    separator: Color(0xFFD5D5DA),
    fill: Color(0xFFE9E9EE),
    brandTint: Color(0xFFECE6EF),
    onBrandTint: Color(0xFF3F2350),
  );

  static const KColors dark = KColors._(
    brand: Color(0xFFB88CD0),
    brandLight: Color(0xFF8E5BA6),
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF98989F),
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9F0A),
    error: Color(0xFFFF453A),
    separator: Color(0xFF3A3A3C),
    fill: Color(0xFF2C2C2E),
    brandTint: Color(0xFF33283A),
    onBrandTint: Color(0xFFE6D6F0),
  );

  /// Android palette (approved design): clean neutral surfaces with the exact
  /// brand for actions. Never generated from the brand, which turns screens pink.
  static const KColors materialLight = KColors._(
    brand: Color(0xFF543063),
    brandLight: Color(0xFF8E5BA6),
    background: Color(0xFFF6F6F7),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF1B1B1D),
    textSecondary: Color(0xFF5C5C62),
    success: Color(0xFF1F8A3D),
    warning: Color(0xFFC25E00),
    error: Color(0xFFC4161C),
    separator: Color(0xFFDCDCDF),
    fill: Color(0xFFECECEE),
    brandTint: Color(0xFFECE6EF),
    onBrandTint: Color(0xFF3F2350),
  );

  static const KColors materialDark = KColors._(
    brand: Color(0xFFB88CD0),
    brandLight: Color(0xFF8E5BA6),
    background: Color(0xFF131314),
    surface: Color(0xFF1E1E20),
    text: Color(0xFFE6E6E8),
    textSecondary: Color(0xFFA6A6AC),
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9F0A),
    error: Color(0xFFFF5449),
    separator: Color(0xFF3B3B3E),
    fill: Color(0xFF2C2C2F),
    brandTint: Color(0xFF33283A),
    onBrandTint: Color(0xFFE6D6F0),
  );

  /// The palette for the current platform and [brightness].
  static KColors forBrightness(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return isDark ? dark : light;
    }
    return isDark ? materialDark : materialLight;
  }

  static KColors of(BuildContext context) =>
      forBrightness(Theme.of(context).brightness);
}

/// Type scale. No font family: platform fonts (SF / SF Arabic on iOS,
/// Roboto / Noto on Android). No colour: set it where the style is used.
abstract final class KType {
  static bool get _material => defaultTargetPlatform != TargetPlatform.iOS;

  /// Screen titles. iOS Large Title / Material headline large.
  static TextStyle get largeTitle => _material
      ? const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, height: 1.25)
      : const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          height: 1.2,
        );

  /// Section titles. iOS Title 2 / Material title large.
  static TextStyle get title => _material
      ? const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 1.27)
      : const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);

  /// Row and card titles, button labels. iOS Headline / Material title medium.
  static TextStyle get headline => _material
      ? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)
      : const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3);

  /// Body text. iOS Body / Material body large.
  static TextStyle get body => _material
      ? const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5)
      : const TextStyle(fontSize: 17, fontWeight: FontWeight.w400, height: 1.3);

  /// Secondary text. iOS Subheadline / Material body medium.
  static TextStyle get subhead => _material
      ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43)
      : const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.3);

  /// Field labels, metadata. iOS Footnote / Material body small.
  static TextStyle get footnote => _material
      ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33)
      : const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.3);

  /// Small print. iOS Caption / Material label small.
  static TextStyle get caption => _material
      ? const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45)
      : const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.3);
}

/// Spacing on a 4/8 grid.
abstract final class KSpace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Minimum size of anything tappable.
  static const double tapTarget = 44;
}

/// Corner radii (drawn as continuous superellipse corners).
abstract final class KRadius {
  static const double field = 14;
  static const double card = 22;
  static const double sheet = 34;
  static const double dialog = 30;

  /// Apple's continuous corners on iOS, Material rounded rectangles on Android.
  static OutlinedBorder shape(
    BorderRadius radius, {
    BorderSide side = BorderSide.none,
  }) => defaultTargetPlatform == TargetPlatform.iOS
      ? RoundedSuperellipseBorder(borderRadius: radius, side: side)
      : RoundedRectangleBorder(borderRadius: radius, side: side);
}

/// Motion durations and curve.
abstract final class KMotion {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Curve curve = Curves.easeOutCubic;

  /// [duration], or zero when the user asked for reduced motion.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
