import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';

enum KButtonVariant { primary, secondary, text, destructive, onPhoto }

/// The Kleano button.
///
/// iOS: a solid capsule like Apple's filled buttons (primary = brand,
/// destructive = `error`, secondary = tinted, text = plain). Buttons in content
/// are not glass; Liquid Glass stays on tabs and navigation. Android: Material 3
/// `FilledButton` (error-coloured when destructive) / tonal `FilledButton` /
/// `TextButton`.
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
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final KButtonVariant variant;
  final bool loading;

  /// Stretch to the available width.
  final bool expand;
  final IconData? icon;

  /// Label colour for text and secondary buttons (e.g. white over photos).
  /// Defaults to brand.
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
        width: expand ? double.infinity : null,
        height: variant == KButtonVariant.text
            ? KSpace.tapTarget
            : (ios ? _iosHeight : _androidHeight),
        child: button,
      ),
    );
  }

  bool get _prominent =>
      variant == KButtonVariant.primary ||
      variant == KButtonVariant.destructive ||
      variant == KButtonVariant.onPhoto;

  /// White fill for the main action over a photo.
  bool get _onPhoto => variant == KButtonVariant.onPhoto;

  Color _fill(KColors c) => _onPhoto
      ? Colors.white
      : (variant == KButtonVariant.destructive ? c.error : c.brand);

  Widget _ios(BuildContext context) {
    final KColors c = KColors.of(context);
    if (variant == KButtonVariant.text) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: KSpace.l),
        onPressed: loading ? null : onPressed,
        child: Text(
          label,
          style: KType.headline.copyWith(color: color ?? c.brand),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    final Color foreground = onPressed == null
        ? c.textSecondary
        : (_onPhoto
              ? c.brand
              : _prominent
              ? Colors.white
              : (color ??
                    (variant == KButtonVariant.secondary
                        ? c.onBrandTint
                        : c.brand)));
    return IgnorePointer(
      ignoring: loading,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: KSpace.xl),
        color: _prominent
            ? _fill(c)
            : (color ?? c.brand).withValues(alpha: 0.14),
        disabledColor: Color.alphaBlend(c.fill, c.surface),
        borderRadius: BorderRadius.circular(_iosHeight / 2),
        onPressed: onPressed,
        child: loading
            ? CupertinoActivityIndicator(color: foreground)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: 20, color: foreground),
                    const SizedBox(width: KSpace.s),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: KType.headline.copyWith(color: foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _android(BuildContext context) {
    final VoidCallback? tap = loading ? null : onPressed;
    final Widget content = loading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _prominent ? Colors.white : KColors.of(context).brand,
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
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
    switch (variant) {
      case KButtonVariant.primary:
        // Material's disabled fill is translucent: content scrolling behind a
        // floating button would show through it.
        final ThemeData theme = Theme.of(context);
        return FilledButton(
          onPressed: tap,
          style: FilledButton.styleFrom(
            disabledBackgroundColor: Color.alphaBlend(
              theme.colorScheme.onSurface.withValues(alpha: 0.12),
              theme.colorScheme.surface,
            ),
          ),
          child: content,
        );
      case KButtonVariant.onPhoto:
        return FilledButton(
          onPressed: tap,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: KColors.of(context).brand,
          ),
          child: content,
        );
      case KButtonVariant.destructive:
        return FilledButton(
          onPressed: tap,
          style: FilledButton.styleFrom(
            backgroundColor: KColors.of(context).error,
            foregroundColor: Colors.white,
          ),
          child: content,
        );
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
