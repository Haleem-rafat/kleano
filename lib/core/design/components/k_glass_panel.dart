import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';

/// The surface of floating panels (sheets, dialogs).
///
/// iOS: Apple's real Liquid Glass (`UIGlassEffect`) with continuous corners,
/// like iOS 26 sheets and alerts. Android and Reduce Transparency: the opaque
/// `surface` token (Material 3, no imitation glass).
class KGlassPanel extends StatelessWidget {
  const KGlassPanel({
    super.key,
    required this.child,
    required this.radius,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Widget content = Padding(padding: padding, child: child);
    if (GlassTokens.useNative && !GlassTokens.reduceTransparency(context)) {
      return ClipRSuperellipse(
        borderRadius: radius,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              // Native glass takes one radius; panels use one on every
              // corner they round. A light surface tint keeps text readable
              // over maps and photos, like Apple's denser alert glass.
              child: NativeGlassView(
                radius: radius.topLeft.x,
                tint: c.surface.withValues(alpha: 0.55),
              ),
            ),
            Material(type: MaterialType.transparency, child: content),
          ],
        ),
      );
    }
    return Material(
      color: c.surface,
      shape: RoundedSuperellipseBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
