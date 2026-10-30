import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';
import 'k_glass_panel.dart';

/// Shows [builder]'s content in a Kleano bottom sheet.
///
/// iOS: a floating Liquid Glass sheet inset from the screen edges (iOS 26).
/// Android: a Material 3 sheet on `surface` with a drag handle.
/// The content scrolls itself if it can be taller than the screen.
Future<T?> showKSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    showDragHandle: false,
    builder: (BuildContext context) => KSheet(child: builder(context)),
  );
}

/// The sheet surface: grabber, padding and keyboard/home-indicator insets.
/// Use [showKSheet] rather than placing it yourself.
class KSheet extends StatelessWidget {
  const KSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final bool floating = GlassTokens.useNative;
    // iOS 26 sheets float 8pt in from the edges and the home indicator.
    final double inset = floating ? KSpace.s : 0;
    final double bottom = floating
        ? math.max(mq.viewPadding.bottom, inset)
        : mq.viewPadding.bottom;
    final BorderRadius radius = floating
        ? BorderRadius.circular(KRadius.sheet)
        : const BorderRadius.vertical(top: Radius.circular(KRadius.sheet));

    return Padding(
      padding: EdgeInsets.only(
        left: inset,
        right: inset,
        bottom: mq.viewInsets.bottom + (floating ? bottom : 0),
      ),
      child: KGlassPanel(
        radius: radius,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            KSpace.xl,
            0,
            KSpace.xl,
            KSpace.xl + (floating ? 0 : bottom),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _Grabber(),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KSpace.s),
      child: Center(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: KColors.of(context).textSecondary.withValues(alpha: 0.4),
          ),
          child: const SizedBox(width: 36, height: 5),
        ),
      ),
    );
  }
}
