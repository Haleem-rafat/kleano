import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// Five stars to tap for a whole-number rating. The chosen stars fill and pop.
class KRatingStars extends StatelessWidget {
  const KRatingStars({super.key, required this.value, required this.onChanged});

  /// 0 means nothing chosen yet.
  final int value;
  final ValueChanged<int> onChanged;

  static const int _count = 5;
  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Duration duration = KMotion.of(context, KMotion.fast);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int star = 1; star <= _count; star++)
          Semantics(
            button: true,
            selected: star == value,
            label: '$star / $_count',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(star);
              },
              child: AnimatedScale(
                scale: star == value ? 1.15 : 1,
                duration: duration,
                curve: Curves.easeOutBack,
                child: Icon(
                  star <= value
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: _size,
                  color: star <= value ? c.warning : c.separator,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
