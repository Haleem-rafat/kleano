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
    separator: Color(0x493C3C43),
    fill: Color(0x29787880),
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
    separator: Color(0x99545458),
    fill: Color(0x5C787880),
  );

  static KColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Type scale. No font family: platform fonts (SF / SF Arabic on iOS,
/// Roboto / Noto on Android). No colour: set it where the style is used.
abstract final class KType {
  static const TextStyle largeTitle =
      TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.15);
  static const TextStyle title =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle headline =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle body =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w400, height: 1.3);
  static const TextStyle subhead =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.3);
  static const TextStyle footnote =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.3);
  static const TextStyle caption =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.3);
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
