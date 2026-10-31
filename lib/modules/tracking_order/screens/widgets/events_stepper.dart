import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/functions/check_step_data.dart';

class EventsStepper extends StatelessWidget {
  final String? status;
  const EventsStepper({super.key, this.status});

  /// Height of one step; the status names beside the stepper use it too.
  static const double rowHeight = 64;
  static const double _dotSize = 20;
  static const int stepCount = 4;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final int step = getStepData(status!).step;
    Color stepColor(int index) => step >= index ? c.brand : c.separator;

    return SizedBox(
      width: KSpace.xxl,
      child: Column(
        children: <Widget>[
          for (int index = 0; index < stepCount; index++) ...<Widget>[
            SizedBox.square(
              dimension: _dotSize,
              child: step + 1 == index
                  ? AvatarGlow(
                      glowColor: c.brand,
                      animate: true,
                      duration: const Duration(milliseconds: 2000),
                      repeat: true,
                      child: _Dot(color: c.brand.withValues(alpha: .5)),
                    )
                  : _Dot(color: stepColor(index)),
            ),
            if (index != stepCount - 1)
              SizedBox(
                height: rowHeight - _dotSize,
                width: KSpace.xs,
                child: ColoredBox(color: stepColor(index)),
              ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: color, shape: const CircleBorder()),
      child: const SizedBox.square(dimension: EventsStepper._dotSize),
    );
  }
}
