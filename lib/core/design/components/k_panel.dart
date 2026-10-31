import 'package:flutter/material.dart';

import '../tokens.dart';

/// The solid surface of sheets and dialogs on both platforms. Text-heavy
/// panels are content, so they are not glass (iOS keeps Liquid Glass for the
/// tab bar and navigation controls only).
class KPanel extends StatelessWidget {
  const KPanel({
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
    return Material(
      color: KColors.of(context).surface,
      shape: KRadius.shape(radius),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}
