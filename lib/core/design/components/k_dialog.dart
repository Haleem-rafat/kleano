import 'package:flutter/material.dart';

import '../tokens.dart';
import 'k_glass_panel.dart';

/// A Kleano alert: optional [icon], [title], optional [message] and up to
/// three [actions] (usually `KButton`s, the main one first) stacked full width.
///
/// iOS: a Liquid Glass panel like iOS 26 alerts. Android: Material 3 surface.
/// Show it with `showDialog(builder: (_) => KDialog(...))`.
class KDialog extends StatelessWidget {
  const KDialog({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.actions = const <Widget>[],
  });

  final Widget? icon;
  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: KSpace.xxxl,
        vertical: KSpace.xxl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: KGlassPanel(
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
                  Center(child: icon),
                  const SizedBox(height: KSpace.l),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: KType.headline.copyWith(color: c.text),
                ),
                if (message != null) ...<Widget>[
                  const SizedBox(height: KSpace.s),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: KType.subhead.copyWith(color: c.textSecondary),
                  ),
                ],
                if (actions.isNotEmpty) const SizedBox(height: KSpace.xl),
                for (int i = 0; i < actions.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: KSpace.s),
                  actions[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
