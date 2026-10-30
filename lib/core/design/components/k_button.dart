import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';

enum KButtonVariant { primary, secondary, text }

/// The Kleano button.
///
/// iOS: Apple's real glass `UIButton` (primary = prominent glass tinted with
/// the brand, secondary = glass, text = plain). Android: Material 3
/// `FilledButton` / tonal `FilledButton` / `TextButton`.
/// While [loading], the button shows progress and ignores taps.
class KButton extends StatelessWidget {
  const KButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KButtonVariant.primary,
    this.loading = false,
    this.expand = true,
    this.icon,
    this.sfSymbol,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final KButtonVariant variant;
  final bool loading;

  /// Stretch to the available width.
  final bool expand;
  final IconData? icon;

  /// SF Symbol shown on iOS instead of [icon].
  final String? sfSymbol;

  /// Label colour for text buttons (e.g. white over photos). Defaults to brand.
  final Color? color;

  static const double _iosHeight = 50;
  static const double _androidHeight = 52;

  @override
  Widget build(BuildContext context) {
    final bool ios = GlassTokens.useNative;
    final Widget button = ios ? _ios(context) : _android(context);
    return Semantics(
      button: true,
      enabled: onPressed != null && !loading,
      label: loading ? '$label…' : null,
      child: SizedBox(
        width: expand
            ? double.infinity
            : (ios && variant != KButtonVariant.text ? _hugWidth(context) : null),
        height: variant == KButtonVariant.text
            ? KSpace.tapTarget
            : (ios ? _iosHeight : _androidHeight),
        child: button,
      ),
    );
  }

  /// Width of a content-hugging glass button. The native `UIButton` is a
  /// platform view with no intrinsic size, so it must be measured here:
  /// unbounded, it gets an infinite frame and iOS crashes.
  double _hugWidth(BuildContext context) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: label, style: KType.headline),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final double symbol = sfSymbol == null ? 0 : KType.headline.fontSize! + KSpace.s;
    final double width = painter.width + symbol + 2 * KSpace.xl;
    painter.dispose();
    return width < KSpace.tapTarget ? KSpace.tapTarget : width.ceilToDouble();
  }

  Widget _ios(BuildContext context) {
    final KColors c = KColors.of(context);
    if (variant == KButtonVariant.text) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: KSpace.l),
        onPressed: loading ? null : onPressed,
        child: Text(label,
            style: KType.headline.copyWith(color: color ?? c.brand),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      );
    }
    if (loading) {
      return LiquidGlass(
        capsule: true,
        tint: variant == KButtonVariant.primary ? c.brand : null,
        child: Center(
          child: CupertinoActivityIndicator(
            color: variant == KButtonVariant.primary ? Colors.white : c.brand,
          ),
        ),
      );
    }
    final bool primary = variant == KButtonVariant.primary;
    return NativeGlassButton(
      onPressed: onPressed,
      title: label,
      sfSymbol: sfSymbol,
      style: primary ? GlassButtonStyle.prominent : GlassButtonStyle.glass,
      tint: primary ? c.brand : null,
      foreground: primary ? Colors.white : c.brand,
      fontSize: KType.headline.fontSize!,
      fallback: const SizedBox.shrink(),
    );
  }

  Widget _android(BuildContext context) {
    final VoidCallback? tap = loading ? null : onPressed;
    final Widget content = loading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == KButtonVariant.primary
                  ? Colors.white
                  : KColors.of(context).brand,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20),
                const SizedBox(width: KSpace.s),
              ],
              Flexible(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          );
    switch (variant) {
      case KButtonVariant.primary:
        return FilledButton(onPressed: tap, child: content);
      case KButtonVariant.secondary:
        return FilledButton.tonal(
          key: const ValueKey<String>('k-button-secondary'),
          onPressed: tap,
          child: content,
        );
      case KButtonVariant.text:
        return TextButton(
          onPressed: tap,
          style: color == null
              ? null
              : TextButton.styleFrom(foregroundColor: color),
          child: content,
        );
    }
  }
}
