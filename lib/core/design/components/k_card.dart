import 'package:flutter/material.dart';

import '../tokens.dart';

/// Content card: surface colour, radius 22 continuous corners, soft shadow in
/// light mode (none in dark mode).
class KCard extends StatelessWidget {
  const KCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(KSpace.l),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final ShapeBorder shape = KRadius.shape(
      BorderRadius.circular(KRadius.card),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: c.surface,
        shadows: dark
            ? null
            : const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
