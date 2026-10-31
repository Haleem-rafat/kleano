import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';

/// A small tappable capsule that floats over content: the saved address,
/// the coins balance. A solid surface capsule with a brand-coloured label on
/// both platforms (raised on Android), 40pt tall.
class KChipButton extends StatelessWidget {
  const KChipButton({
    super.key,
    this.maxWidth = 200,
    required this.label,
    required this.onTap,
    this.leading,
    this.trailing,
    this.semanticLabel,
    this.onPhoto = false,
  });

  final String label;
  final VoidCallback? onTap;

  /// Longest the chip may grow before its label is cut.
  final double maxWidth;
  final Widget? leading;
  final Widget? trailing;
  final String? semanticLabel;

  /// Liquid Glass with white text, for a chip floating over a photo. On iOS
  /// it is Apple's clear glass button, with its own press response.
  final bool onPhoto;

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Color fg = onPhoto ? Colors.white : c.brand;
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (leading != null) ...<Widget>[
            IconTheme.merge(
              data: IconThemeData(color: fg, size: 18),
              child: leading!,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KType.subhead.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: KSpace.xs),
            IconTheme.merge(
              data: IconThemeData(color: fg, size: 18),
              child: trailing!,
            ),
          ],
        ],
      ),
    );
    if (onPhoto && GlassTokens.useNative) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: NativeGlassButton(
                  onPressed: onTap,
                  style: GlassButtonStyle.clear,
                  semanticLabel: semanticLabel ?? label,
                  fallback: const SizedBox.shrink(),
                ),
              ),
              IgnorePointer(child: Center(widthFactor: 1, child: content)),
            ],
          ),
        ),
      );
    }
    final Widget chip = onPhoto
        ? LiquidGlass(
            capsule: true,
            tint: KColors.light.brand.withValues(alpha: 0.4),
            child: Center(widthFactor: 1, child: content),
          )
        : Material(
            color: c.surface,
            elevation: GlassTokens.useNative ? 0 : 1,
            shadowColor: Colors.black26,
            shape: const StadiumBorder(),
            child: Center(widthFactor: 1, child: content),
          );
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(height: height, child: chip),
        ),
      ),
    );
  }
}
