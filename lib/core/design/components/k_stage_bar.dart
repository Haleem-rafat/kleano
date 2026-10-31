import 'package:flutter/material.dart';

import '../tokens.dart';

/// Progress through named stages on one line: reached stages fill in, the
/// latest is named in bold, and the bar turns green once the last is reached.
class KStageBar extends StatelessWidget {
  const KStageBar({
    super.key,
    required this.stages,
    required this.step,
    this.semanticLabel,
  });

  final List<String> stages;

  /// Index of the latest reached stage; -1 means none yet.
  final int step;

  /// Read by screen readers instead of the stage names.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Duration duration = KMotion.of(context, KMotion.slow);
    final bool done = step >= stages.length - 1;
    return Semantics(
      label: semanticLabel ?? (step < 0 ? null : stages[step]),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < stages.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: KSpace.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AnimatedContainer(
                    duration: duration,
                    curve: KMotion.curve,
                    height: KSpace.s,
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: i <= step ? (done ? c.success : c.brand) : c.fill,
                    ),
                  ),
                  const SizedBox(height: KSpace.xs),
                  Text(
                    stages[i],
                    maxLines: 2,
                    style: KType.caption.copyWith(
                      color: i == step ? c.text : c.textSecondary,
                      fontWeight: i == step ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
