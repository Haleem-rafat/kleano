import 'package:flutter/material.dart';

import '../tokens.dart';

/// Progress through named stages on one line: reached stages fill in, the
/// stage in progress gently pulses, and the bar turns green at the last stage.
class KStageBar extends StatefulWidget {
  const KStageBar({
    super.key,
    required this.stages,
    required this.step,
    this.semanticLabel,
    this.pulse = false,
  });

  final List<String> stages;

  /// Index of the latest reached stage; -1 means none yet.
  final int step;

  /// Read by screen readers instead of the stage names.
  final String? semanticLabel;

  /// Animates the stage being worked towards. Off in lists and when the user
  /// asked for reduced motion.
  final bool pulse;

  @override
  State<KStageBar> createState() => _KStageBarState();
}

class _KStageBarState extends State<KStageBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  bool get _done => widget.step >= widget.stages.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(KStageBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final bool run =
        widget.pulse && !_done && !MediaQuery.disableAnimationsOf(context);
    if (run && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!run && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Duration duration = KMotion.of(context, KMotion.slow);
    final int active = widget.step + 1;
    return Semantics(
      label:
          widget.semanticLabel ??
          (widget.step < 0 ? null : widget.stages[widget.step]),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < widget.stages.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: KSpace.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      AnimatedContainer(
                        duration: duration,
                        curve: KMotion.curve,
                        height: KSpace.s,
                        decoration: ShapeDecoration(
                          shape: const StadiumBorder(),
                          color: i <= widget.step
                              ? (_done ? c.success : c.brand)
                              : c.fill,
                        ),
                      ),
                      if (widget.pulse && !_done && i == active)
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: FadeTransition(
                              opacity: _pulse,
                              child: DecoratedBox(
                                decoration: ShapeDecoration(
                                  shape: const StadiumBorder(),
                                  color: c.brand,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: KSpace.xs),
                  Text(
                    widget.stages[i],
                    maxLines: 2,
                    style: KType.caption.copyWith(
                      color: i == widget.step ? c.text : c.textSecondary,
                      fontWeight: i == widget.step ? FontWeight.w600 : null,
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
