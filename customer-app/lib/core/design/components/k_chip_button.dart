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
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onTap;

  /// Longest the chip may grow before its label is cut.
  final double maxWidth;
  final Widget? leading;
  final String? semanticLabel;

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (leading != null) ...<Widget>[
            IconTheme.merge(
              data: IconThemeData(color: c.brand, size: 18),
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
                color: c.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    final Widget chip = Material(
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
