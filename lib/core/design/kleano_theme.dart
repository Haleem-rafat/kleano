import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'liquid_glass.dart';
import 'tokens.dart';

/// The Kleano theme: real Material 3 on Android, and the base for Apple-style
/// controls on iOS. Built only from [KColors], [KType], [KSpace], [KRadius];
/// documented in `docs/design-system.md`.
ThemeData kleanoTheme({required Brightness brightness}) {
  final KColors c = KColors.forBrightness(brightness);
  final bool ios = defaultTargetPlatform == TargetPlatform.iOS;

  final ColorScheme scheme =
      ColorScheme.fromSeed(
        seedColor: KColors.light.brand,
        brightness: brightness,
      ).copyWith(
        primary: c.brand,
        onPrimary: Colors.white,
        onSurface: c.text,
        onSurfaceVariant: c.textSecondary,
        error: c.error,
        outlineVariant: c.separator,
      );

  TextStyle t(TextStyle s, Color color) => s.copyWith(color: color);
  final TextTheme text = TextTheme(
    displaySmall: t(KType.largeTitle, c.text),
    headlineSmall: t(KType.title, c.text),
    titleLarge: t(KType.title, c.text),
    titleMedium: t(KType.headline, c.text),
    titleSmall: t(KType.subhead.copyWith(fontWeight: FontWeight.w600), c.text),
    bodyLarge: t(KType.body, c.text),
    bodyMedium: t(KType.subhead, c.text),
    bodySmall: t(KType.footnote, c.textSecondary),
    labelLarge: t(KType.headline, c.text),
    labelMedium: t(KType.footnote, c.textSecondary),
    labelSmall: t(KType.caption, c.textSecondary),
  );

  final ButtonStyle capsule = ButtonStyle(
    shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
    minimumSize: const WidgetStatePropertyAll<Size>(Size(64, 52)),
    padding: const WidgetStatePropertyAll<EdgeInsets>(
      EdgeInsets.symmetric(horizontal: KSpace.xl),
    ),
    textStyle: WidgetStatePropertyAll<TextStyle>(KType.headline),
  );

  OutlineInputBorder field(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(KRadius.field),
    borderSide: width == 0
        ? BorderSide.none
        : BorderSide(color: color, width: width),
  );

  final ThemeData base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    canvasColor: c.background,
    textTheme: text,
    dividerColor: c.separator,
    filledButtonTheme: FilledButtonThemeData(style: capsule),
    elevatedButtonTheme: ElevatedButtonThemeData(style: capsule),
    outlinedButtonTheme: OutlinedButtonThemeData(style: capsule),
    textButtonTheme: TextButtonThemeData(
      style: capsule.copyWith(
        minimumSize: const WidgetStatePropertyAll<Size>(Size(44, 44)),
        foregroundColor: WidgetStatePropertyAll<Color>(c.brand),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      // iOS: filled field. Android: Material 3 outlined field.
      filled: ios,
      fillColor: ios ? c.fill : null,
      hintStyle: KType.body.copyWith(color: c.textSecondary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KSpace.l,
        vertical: KSpace.m + 2,
      ),
      border: ios ? field(c.brand, 0) : field(c.separator, 1),
      enabledBorder: ios ? field(c.brand, 0) : field(c.textSecondary, 1),
      focusedBorder: field(c.brand, 2),
      errorBorder: field(c.error, 1.5),
      focusedErrorBorder: field(c.error, 2),
      errorStyle: KType.footnote.copyWith(color: c.error),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: KRadius.shape(BorderRadius.circular(KRadius.card)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      shape: KRadius.shape(BorderRadius.circular(KRadius.dialog)),
      titleTextStyle: t(KType.headline, c.text),
      contentTextStyle: t(KType.subhead, c.text),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.brand.withValues(alpha: 0.14),
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(
        KType.footnote.copyWith(fontWeight: FontWeight.w500, color: c.text),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
        side: WidgetStatePropertyAll<BorderSide>(
          BorderSide(color: c.separator),
        ),
      ),
    ),
    // Android keeps Material's own switch colours from the scheme.
    switchTheme: ios
        ? SwitchThemeData(
            thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
            trackColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> s) =>
                  s.contains(WidgetState.selected) ? c.success : c.fill,
            ),
          )
        : null,
    listTileTheme: ListTileThemeData(
      minVerticalPadding: KSpace.m,
      titleTextStyle: t(KType.body, c.text),
      subtitleTextStyle: t(KType.subhead, c.textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.text,
      elevation: 0,
      // iOS centres the title; Material starts it after the back arrow.
      centerTitle: ios,
      titleTextStyle: t(ios ? KType.headline : KType.title, c.text),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: t(KType.subhead, Colors.white),
    ),
  );

  final ThemeData glass = LiquidGlassTheme.apply(base, primary: c.brand);
  // LiquidGlassTheme gives sheets/dialogs light glass surfaces; keep the
  // token surfaces so dark mode and contrast stay correct.
  return glass.copyWith(
    bottomSheetTheme: glass.bottomSheetTheme.copyWith(
      backgroundColor: c.surface,
      modalBackgroundColor: c.surface,
    ),
    dialogTheme: glass.dialogTheme.copyWith(
      backgroundColor: c.surface,
      shape: KRadius.shape(BorderRadius.circular(KRadius.dialog)),
    ),
    cardTheme: base.cardTheme,
    // Android: the bar takes a tonal surface when content scrolls under it.
    appBarTheme: ios
        ? glass.appBarTheme
        : glass.appBarTheme.copyWith(
            scrolledUnderElevation: 3,
            surfaceTintColor: Colors.transparent,
            backgroundColor: c.background,
          ),
    // Android keeps Material's own switch instead of the iOS-style override.
    switchTheme: ios ? glass.switchTheme : const SwitchThemeData(),
  );
}
