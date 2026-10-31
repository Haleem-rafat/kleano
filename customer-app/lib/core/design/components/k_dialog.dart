import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';
import 'k_panel.dart';

/// A Kleano alert: optional [icon], [title], optional [message], optional
/// [content] such as stars, and up to three [actions] (usually `KButton`s, the
/// main one first). A plain `Icon` sits on a soft circle of its own colour.
///
/// iOS: centred text with stacked buttons, like Apple's alerts. Android: a
/// Material 3 dialog with start-aligned text and buttons along the bottom end.
/// Show it with `showDialog(builder: (_) => KDialog(...))`.
class KDialog extends StatelessWidget {
  const KDialog({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.content,
    this.actions = const <Widget>[],
  });

  final Widget? icon;
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget> actions;

  static const double _badge = 64;

  Widget _icon(KColors c) {
    final Widget? given = icon;
    if (given is! Icon) return given!;
    final Color color = given.color ?? c.brand;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: SizedBox.square(
        dimension: _badge,
        child: Icon(given.icon, size: KSpace.xxxl, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool ios = GlassTokens.useNative;
    final TextAlign align = ios ? TextAlign.center : TextAlign.start;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: KSpace.xxxl,
        vertical: KSpace.xxl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: KPanel(
          radius: BorderRadius.circular(KRadius.dialog),
          padding: const EdgeInsets.fromLTRB(
            KSpace.xxl,
            KSpace.xxl,
            KSpace.xxl,
            KSpace.xl,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  if (ios)
                    Center(child: _icon(c))
                  else
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _icon(c),
                    ),
                  const SizedBox(height: KSpace.l),
                ],
                Text(
                  title,
                  textAlign: align,
                  style: KType.title.copyWith(color: c.text),
                ),
                if (message != null) ...<Widget>[
                  const SizedBox(height: KSpace.s),
                  Text(
                    message!,
                    textAlign: align,
                    style: KType.subhead.copyWith(color: c.textSecondary),
                  ),
                ],
                if (content != null) ...<Widget>[
                  const SizedBox(height: KSpace.l),
                  content!,
                ],
                if (actions.isNotEmpty) const SizedBox(height: KSpace.xl),
                if (ios)
                  for (int i = 0; i < actions.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: KSpace.s),
                    actions[i],
                  ]
                else if (actions.isNotEmpty)
                  // Material puts the main action last, at the bottom end.
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    spacing: KSpace.s,
                    overflowSpacing: KSpace.s,
                    children: <Widget>[
                      for (final Widget action in actions.reversed)
                        IntrinsicWidth(child: action),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
