import 'package:flutter/material.dart';

import 'liquid_glass.dart';
import 'tokens.dart';

/// The Kleano theme (Material 3 Expressive on Android, base for the native
/// Liquid Glass controls on iOS). Built only from [KColors], [KType],
/// [KSpace], [KRadius]; documented in `docs/design-system.md`.
ThemeData kleanoTheme({required Brightness brightness}) {
  final KColors c = brightness == Brightness.dark ? KColors.dark : KColors.light;

  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: KColors.light.brand,
    brightness: brightness,
  ).copyWith(
    primary: c.brand,
    onPrimary: Colors.white,
    surface: c.surface,
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
        EdgeInsets.symmetric(horizontal: KSpace.xl)),
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
      filled: true,
      fillColor: c.fill,
      hintStyle: KType.body.copyWith(color: c.textSecondary),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: KSpace.l, vertical: KSpace.m + 2),
      border: field(c.brand, 0),
      enabledBorder: field(c.brand, 0),
      focusedBorder: field(c.brand, 2),
      errorBorder: field(c.error, 1.5),
      focusedErrorBorder: field(c.error, 2),
      errorStyle: KType.footnote.copyWith(color: c.error),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(KRadius.card)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(KRadius.dialog)),
      titleTextStyle: t(KType.headline, c.text),
      contentTextStyle: t(KType.subhead, c.text),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.brand.withValues(alpha: 0.14),
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(KType.caption),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
        side: WidgetStatePropertyAll<BorderSide>(BorderSide(color: c.separator)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) =>
          s.contains(WidgetState.selected) ? c.success : c.fill),
    ),
    listTileTheme: ListTileThemeData(
      minVerticalPadding: KSpace.m,
      titleTextStyle: t(KType.body, c.text),
      subtitleTextStyle: t(KType.subhead, c.textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.text,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: t(KType.headline, c.text),
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
    dialogTheme: glass.dialogTheme.copyWith(backgroundColor: c.surface),
    cardTheme: base.cardTheme,
  );
}
